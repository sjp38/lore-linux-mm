Subject: Re: get_free pages!!
Message-ID: <OF5F52B32A.64EF335A-ON88256AB7.005F42B4@boulder.ibm.com>
From: "Badari Pulavarty" <badari@us.ibm.com>
Date: Wed, 29 Aug 2001 10:22:23 -0700
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jalajadevi Ganapathy <JGanapathy@storage.com>
Cc: Andrew Kay <Andrew.J.Kay@syntegra.com>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, owner-linux-mm@kvack.org, Daniel Phillips <phillips@bonn-fries.net>
List-ID: <linux-mm.kvack.org>

Just to let you know, order greater than 5 DOES NOT mean more than 5 pages.

value "order" means 2^order pages.

Thanks,
Badari



                                                                                                         
                    "Jalajadevi                                                                          
                    Ganapathy"           To:     Andrew Kay <Andrew.J.Kay@syntegra.com>                  
                    <JGanapathy@st       cc:     Daniel Phillips <phillips@bonn-fries.net>, Marcelo      
                    orage.com>            Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org         
                    Sent by:             Subject:     get_free pages!!                                   
                    owner-linux-mm                                                                       
                    @kvack.org                                                                           
                                                                                                         
                                                                                                         
                    08/29/01 09:44                                                                       
                    AM                                                                                   
                                                                                                         
                                                                                                         




How can i get memory pagest greater than order 5.
If I pass, the value greater than 5 as order, my get_free_pages fails.
How can i get more than 5 pages!!

Thanks
Jalaja






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
