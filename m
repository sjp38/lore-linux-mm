Date: Thu, 8 Jun 2000 15:00:19 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] page aging for 2.2.16
Message-ID: <20000608150019.E3886@redhat.com>
References: <20000608031635.A353@acs.ucalgary.ca> <20000608144126.E8549@krusty.e-technik.uni-dortmund.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608144126.E8549@krusty.e-technik.uni-dortmund.de>; from ma@dt.e-technik.uni-dortmund.de on Thu, Jun 08, 2000 at 02:41:26PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthias Andree <ma@redhat.com>, Neil Schemenauer <nascheme@enme.ucalgary.ca>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 08, 2000 at 02:41:26PM +0200, Matthias Andree wrote:
> * Neil Schemenauer (nascheme@enme.ucalgary.ca) [000608 11:21]:
> > I timed a kernel compile with -j 20 to test the cost of the
> 
> you mean: make -j 2 MAKE="make -j 10"? Recursive make easily breaks its
> -j option if -j is given a numeric parameter.

On modern versions of Gnu Make, "-j <n>" uses a "jobserver" facility to make
sure that the parent and all child make processes share the same pool of
up to <n> compilation tasks.  It handles recursion properly nowadays.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
