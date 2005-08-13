Date: Sat, 13 Aug 2005 16:08:18 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Zoned CART
Message-ID: <20050813190818.GA7652@dmt.cnet>
References: <1123857429.14899.59.camel@twins> <42FCC359.20200@andrew.cmu.edu> <20050812230825.GB11168@dmt.cnet> <42FE435E.6000806@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42FE435E.6000806@andrew.cmu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rahul Iyer <rni@andrew.cmu.edu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> >+	node->offset = page->index;
> >+	node->mapping = (unsigned long) page->mapping;
> >+	node->inode = get_inode_num(page->mapping);
> >
> >You can compress these tree fields into a single one with a hash function.
> > 
> >
> Yes, but then you would not be able to handle hash collisions. Are we 
> prepared to give up this property?

I suppose collisions should be quite rare.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
