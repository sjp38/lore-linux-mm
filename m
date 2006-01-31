Date: Tue, 31 Jan 2006 13:57:19 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 2/4] Split the free lists into kernel and user parts
Message-ID: <20060131195718.GA8496@dmt.cnet>
References: <20060120115415.16475.8529.sendpatchset@skynet.csn.ul.ie> <20060120115455.16475.93688.sendpatchset@skynet.csn.ul.ie> <20060122133147.GA4186@dmt.cnet> <Pine.LNX.4.58.0601230937200.11319@skynet> <20060123191341.GA4892@dmt.cnet> <Pine.LNX.4.58.0601261548190.3279@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0601261548190.3279@skynet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, jschopp@austin.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> > Other codepaths which touch page->flags do not hold any lock, so you
> > really must use atomic operations, except when you've guarantee that the
> > page is being freed and won't be reused.
> >
> 
> Understood, so I took another look to be sure;
> 
> PageEasyRclm() is used on pages that are about to be freed to the main
> or per-cpu allocator so it should be safe.
> 
> __SetPageEasyRclm is called when the page is about to be freed. It should
> be safe from concurrent access.
> 
> __ClearPageEasyRclm is called when the page is about to be allocated. It
> should be safe.
> 
> I think it is guaranteed that there are on concurrent accessing of the
> page flags. Is there something I have missed?

Nope, you are right.

The usage is safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
