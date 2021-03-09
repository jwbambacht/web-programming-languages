module pages/portfolio

page portfolios() {
	
	main()
	
	define body() {
		overviewPortfolio()
	}
}

page portfolio(page: String, p: Portfolio) {
	
	init {
		
		if(!((page == "view" || page == "edit") && p != null)) {
			return portfolios();	
		}
		
		if(p.user != currentUser()) {
			return portfolios();
		}
		
		// if(p.user != securityContext.principal) {
		// 	"This portfolio is not owned by me"	
		// }
	
		// if(page != "view" || page != "edit") {
		// 	return portfolios();
		// }
		// if(((page == "view" || page == "edit") && p == null) || page == null || page == "") {
		// 	return portfolios();	
		// }	
	}
	
	main()
	
	define body() {
		case (page) {
			"view" { viewPortfolio(p) }
			"edit" { editPortfolio(p) }
		}
	}
}

template viewPortfolio(portfolio: Portfolio) {
	
	init {
		if(portfolio.assets.length == 0) {
			return portfolio("edit",portfolio);
		} 
	}

	pageTitle {
		span[class="fw-bold fs-1 me-2"] {
			"Portfolio: "
		}
		span[class="fs-3"] {
			"~portfolio.name"	
		}
	}
	
	pageSubTitle {
		if(portfolio.assets.length == 0) {
			"Please edit your portfolio and add some assets to start tracking your value!" 
		}else{
			"Your portfolio consists of the following assets:"	
		}
			
	}
		
	if(portfolio.assets.length > 0) {
		row[class="portfolio", portfolio-id=""+portfolio.id] {
			col("col-12 col-md-4 col-xl-4 mb-3") {
				card[class="border-0"] {
					card_body[class="p-3 rounded-3"] {
						badge[class="bg-darker w-100 py-2"] {
							div[class="fs-3 fw-bold portfolio-value"] {
								"$~nDecimals(portfolio.value,2, true)"
							}
							div[class="p-0 fs-7 mt-2 portfolio-changes"] {
								badge[class="portfolio-change-percentage me-2 ~bgColor(portfolio.changePercentage)"] {
									icon("~arrowIcon(portfolio.changePercentage)")
									"~nDecimals(absolute(portfolio.changePercentage),2, true)%"	
								}
								badge[class="portfolio-change-value me-2 ~bgColor(portfolio.changeValue)"] {
									icon("~arrowIcon(portfolio.changeValue)")
									"$~nDecimals(absolute(portfolio.changeValue),2, true)"
								}
								"(1D)"
							}
						}
						div[class="d-none", id="portfolio-chart"] {
							figure[class="highcharts-figure mb-0"] {
								div[class="w-100 chart-spinner-container"]	{
									div[class="spinner-grow text-light", role="status"] {
										span[class="visually-hidden"] {
											"Loading..."
										}
									}
								}
	
								div[id="portfolio-chart-container", class="w-100 h-200px"]
							}
							col("col-12") {
								row[class="mx-1 text-center"] {
									badge[class="col btn btn-dark badge me-1 change-chart-interval selected-interval text-white", data-interval="1"] { 
										"1D"
									}
									badge[class="col btn btn-dark badge me-1 change-chart-interval text-muted", data-interval="3"] { 
										"3D"
									}
									badge[class="col btn btn-dark badge change-chart-interval text-muted", data-interval="7"] { 
										"7D"
									}
								}
							}
						}
					}
				}
			}
		
			col("col-12 col-md-8 col-xl-8 portfolio-list") {
				col("col-12")[class="mb-2"] {
					card[class="border-0 bg-dark"] {
						row {
							col("col")[class="mt-auto mb-auto w-100"] {
								row[class="ps-3 py-2"] {
									col("col col-icon") {}
									col("col") {
										badge[class="bg-darker"] {
											"Currency"	
										}
									}
									col("col") {
										badge[class="bg-darker"] {
											"Price/Change"
										}
									}
									col("col d-none d-lg-block") {
										badge[class="bg-darker"] {
											"High/Low"
										}
									}
									col("col d-none d-sm-block") {
										badge[class="bg-darker"] {
											"Balance/Value"
										}
									}
								}
							}
							div[class="w-56px"] {}
						}
					}
				}
				
				for(asset : Asset in portfolio.assets where asset.active == true && asset.portfolio.user == currentUser() order by asset.order asc) {
					col("col-12")[class="mb-2 portfolio-row", data-symbol=asset.token.symbol, data-balance=asset.balance, data-price="", data-value=""] {
						card[class="border-0"] {
							row {
								col("col")[class="mt-auto mb-auto w-100 py-3"] {
									row[class="ps-3"] {
										col("col col-icon") {
											badge[class="bg-darker p-2"] {	
												image("images/icons/"+asset.token.symbol+".png")[width="32px",height="32px"]
											}
										}
										col("col") {
											badge[class="fw-bold"] {
												output(asset.token.name)
											}
											br
											badge[class="text-muted"] {
												output(asset.token.symbol)
											}
										}
										col("col") {
											badge[class="asset-price", data-symbol=asset.token.symbol] {
												"$~nDecimals(asset.token.data.price,2, true)"
											}
											br
											badge[class="asset-change ~textColor(asset.token.data.change)", data-symbol=asset.token.symbol] {
												icon("~arrowIcon(asset.token.data.change)")
												"~nDecimals(absolute(asset.token.data.change),2, true)%"
											}
										}
										col("col d-none d-lg-block") {
											icon("bi-arrow-up-short")[class="text-white"]
											badge[class="asset-high text-success", data-symbol=asset.token.symbol] {
												"$~nDecimals(asset.token.data.high,2, true)"
											}
											br
											icon("bi-arrow-down-short")[class="text-white"]
											badge[class="asset-low text-danger", data-symbol=asset.token.symbol] {
												"$~nDecimals(asset.token.data.low,2, true)"
											}
										}
										col("col d-none d-sm-block") {
											badge[class=""] {
												span[class="asset-balance", data-symbol=asset.token.symbol, data-balance=asset.balance] {
													"~nDecimals(asset.balance,2, true)"
												}
												span[class="ps-1"] {
													output(asset.token.symbol)
												}
											}
											br
											badge[class="asset-value", data-symbol=asset.token.symbol] {
												"$~nDecimals(asset.value,2, true)"
											}
										}
									}
								}
								navigate(asset(asset))[class="w-auto"] {
									div[class="portfolio-asset-view h-100 d-flex align-items-center text-white fs-2 rounded-0 rounded-end"] {
										icon("bi-chevron-right")
									}
								}
							}
						}
					}
				}
				
				col("col-12")[class="mb-2"] {
					card("bg-dark")[class="border-0"] {
						row {
							col("col")[class="w-100 text-center p-0"] {
								navigate(portfolio("edit",portfolio))[class="fs-7 text-muted"] {
									"Edit Portfolio"
								}
							}
						}
					}
				}
			}
		}
	}
}

template overviewPortfolio() {
	
	var portfolio := Portfolio{}
		
	pageTitle {
		"Portfolio Overview"
	}
	
	pageSubTitle {
		"You have added the following portfolios."
	}
	
	row[class="mt-4"] {
		if(getPortfolios().length > 0) {
			col("col-12 col-lg-3 mb-3") {
				card[class="border-0"] {
					card_body[class="p-3 rounded-3"] {
						badge[class="bg-darker w-100 py-2 mb-3 lh-1-25"] {
							span[class="fs-4 text-secondary"] {
								"Total Value"
							}
							div[class="portfolios-value fs-2 text-white"] {
								"$~nDecimals(currentUser().value,2, true)"
							}
						}
						
						badge[class="d-flex align-items-center fs-7 text-secondary fw-bold"] {
							span[class="me-auto text-muted"] {
								"Total Cost:"
							}
							span {
								"$~nDecimals(currentUser().cost,2, true)"
							}
						}
						
						badge[class="d-flex align-items-center fs-7 text-secondary fw-bold"] {
							span[class="me-auto text-muted"] {
								"Total Profit:"
							}
							span {
								"$~nDecimals(currentUser().value-currentUser().cost,2, true)"
							}
						}
					}
				}
			}
			
			col("col-12 col-md-6 col-lg-5") {
				for(p : Portfolio) {
					col("col-12")[class="mb-3"] {
						card[class="border-0"] {
							row[class="portfolio"] {
								col("col")[class="mt-auto mb-auto ps-3 py-3 pe-0"] {
									row[class="ps-3 align-items-center py-2"] {
										col("col-12") {
											div[class="fs-4 d-flex"] {
												span[class="fw-bold me-auto d-flex align-items-center"] {
													"~p.name" 
													badge[class="portfolio-change-percentage ms-2 fs-8 ~bgColor(p.changePercentage)"] {
														icon("~arrowIcon(p.changePercentage)")
														"~nDecimals(absolute(p.changePercentage),2, true)%"	
													}
												}	
												div[class="portfolio-value"] {
													"$~nDecimals(p.value,2, true)"
												}
											}
										}
										col("col-12") {
											if(p.assets.length > 0) {
												for(asset : Asset in p.assets) {
													badge[class="bg-darker portfolio-row me-2", data-symbol=asset.token.symbol, data-balance=asset.balance, data-price="", data-value=""] {
														"~asset.token.symbol"
													}
												}
											}else{
												"No assets in portfolio."
											}
										}
									}
								}
								navigate(portfolio("view",p))[class="w-auto ps-2"] {
									div[class="portfolio-asset-view h-100 d-flex align-items-center text-white fs-2 rounded-0 rounded-end"] {
									// div[class="portfolio-asset-view pt-3 pb-3 text-white fs-2 rounded-0 rounded-end"] {
										icon("bi-chevron-right")
									}
								}		
							}
						}
					}
				}
			}
		}
		col("col-12 col-md-6 col-lg-4 mb-3")[class="mb-3"] {
			form {
				card[class="border-lighter"] {
					card_header[class="fs-3"] {
						"Create Portfolio"
					}
					card_body {
						row[class="align-items-center mb-2"] {
							col("col-12 col-md-3") {
								label("Name")[class="col-form-label text-white fst-italic fw-bold"]
							}
							col("col-12 col-md-9") {
								input(portfolio.name)[class="form-control btn-dark w-100"] {
									validate((portfolio.name) != "", "Please fill in a portfolio name")
								}	
							}
						}
						row[class="align-items-center"] {
							col("col-12") {
								row[class="align-items-center"] {
									col("col-12 text-end") {
										submit action {
											portfolio.user := currentUser();
											portfolio.save();
											return url("./portfolio/edit/~portfolio.id");
										}[class="btn btn-sm btn-success"] {
											"Continue " icon("bi-arrow-right")
										}							 
									}
								}
							}
						}
					}
				}
			}	
		}
	}
}

template editPortfolio(p: Portfolio) {
		
	pageTitle {
		"Edit Portfolio" 
	}
	
	pageSubTitle {
		"Change the portfolio's name or assets, adjust your balance or set the asset order."
	}
	
	portfolio_content(p)
}