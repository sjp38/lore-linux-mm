From: "Jalajadevi Ganapathy" <JGanapathy@storage.com>
Subject: Re: get_free pages!!
Message-ID: <OFB7807547.807757AE-ON85256AB7.0061862E@storage.com>
Date: Wed, 29 Aug 2001 13:46:31 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <badari@us.ibm.com>
Cc: Jalajadevi Ganapathy <JGanapathy@storage.com>, Andrew Kay <Andrew.J.Kay@syntegra.com>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, owner-linux-mm@kvack.org, Daniel Phillips <phillips@bonn-fries.net>
List-ID: <linux-mm.kvack.org>


Sorry for my hurried question.
Actually I want to allocate more than MAX_ORDER




"Badari Pulavarty" <badari@us.ibm.com>@kvack.org on 08/29/2001 01:22:23 PM

Sent by:  owner-linux-mm@kvack.org


To:   "Jalajadevi Ganapathy" <JGanapathy@storage.com>
cc:   Andrew Kay <Andrew.J.Kay@syntegra.com>, linux-mm@kvack.org, Marcelo
      Tosatti <marcelo@conectiva.com.br>, owner-linux-mm@kvack.org, Daniel
      Phillips <phillips@bonn-fries.net>

Subject:  Re: get_free pages!!

Just to let you know, order greater than 5 DOES NOT mean more than 5 pages.

value "order" means 2^order pages.

Thanks,
Badari




                    "Jalajadevi

                    Ganapathy"           To:     Andrew Kay
<Andrew.J.Kay@syntegra.com>
                    <JGanapathy@st       cc:     Daniel Phillips
<phillips@bonn-fries.net>, Marcelo
                    orage.com>            Tosatti
<marcelo@conectiva.com.br>, linux-mm@kvack.org
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




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
