Date: Thu, 8 Jun 2000 14:41:26 +0200
From: Matthias Andree <ma@dt.e-technik.uni-dortmund.de>
Subject: Re: [PATCH] page aging for 2.2.16
Message-ID: <20000608144126.E8549@krusty.e-technik.uni-dortmund.de>
References: <20000608031635.A353@acs.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608031635.A353@acs.ucalgary.ca>; from nascheme@enme.ucalgary.ca on Thu, Jun 08, 2000 at 03:16:36AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Schemenauer <nascheme@enme.ucalgary.ca>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

* Neil Schemenauer (nascheme@enme.ucalgary.ca) [000608 11:21]:
> I timed a kernel compile with -j 20 to test the cost of the

you mean: make -j 2 MAKE="make -j 10"? Recursive make easily breaks its
-j option if -j is given a numeric parameter.

Will try your patch later. 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
