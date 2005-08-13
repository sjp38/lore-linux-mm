Date: Sat, 13 Aug 2005 17:30:20 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Zoned CART
In-Reply-To: <20050813190818.GA7652@dmt.cnet>
Message-ID: <Pine.LNX.4.61.0508131729510.23457@chimarrao.boston.redhat.com>
References: <1123857429.14899.59.camel@twins> <42FCC359.20200@andrew.cmu.edu>
 <20050812230825.GB11168@dmt.cnet> <42FE435E.6000806@andrew.cmu.edu>
 <20050813190818.GA7652@dmt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Rahul Iyer <rni@andrew.cmu.edu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Aug 2005, Marcelo Tosatti wrote:

> > Yes, but then you would not be able to handle hash collisions. Are we 
> > prepared to give up this property?
> 
> I suppose collisions should be quite rare.

Rare enough to not be a performance issue - and remember
that page replacement algorithms are just about performance.

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
