From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [patch 3/4] spufs: convert nopfn to fault
Date: Fri, 2 May 2008 19:43:53 +1000
References: <20080502031903.GD11844@wotan.suse.de> <200805021406.38980.jk@ozlabs.org> <20080502044725.GI11844@wotan.suse.de>
In-Reply-To: <20080502044725.GI11844@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200805021943.54638.jk@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

Hi Nick,

> > Acked-by: Jeremy Kerr <jk@ozlabs.org>
>
> Great, thanks very much!

After more testing, it looks like these patches cause a huge increase in 
load (ie, system is unresponsive for large amounts of time) for various 
tests which depend on the fault path.

I need to get some quantitative numbers, but it looks like oprofile is 
broken at the moment. More debugging coming..

Cheers,


Jeremy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
