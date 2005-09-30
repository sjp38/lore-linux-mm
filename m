Subject: Re: [PATCH] earlier allocation of order 0 pages from pcp in
	__alloc_pages
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <20050929161118.27f9f1eb.akpm@osdl.org>
References: <20050929150155.A15646@unix-os.sc.intel.com>
	 <719460000.1128034108@[10.10.2.4]>  <20050929161118.27f9f1eb.akpm@osdl.org>
Content-Type: text/plain
Date: Thu, 29 Sep 2005 18:58:25 -0700
Message-Id: <1128045505.3735.31.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Hicks <mort@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-09-29 at 16:11 -0700, Andrew Morton wrote:
> "Martin J. Bligh" <mbligh@mbligh.org> wrote:
> >
> > It looks like we're now dropping into direct reclaim as the first thing
> > in __alloc_pages before even trying to kick off kswapd. When the hell
> > did that start? Or is that only meant to trigger if we're already below
> > the low watermark level?
> 
> That's all the numa goop which Martin Hicks added.  It's all disabled if
> z->reclaim_pages is zero (it is).  However we could be testing that flag a
> bit earlier, I think.
> 
> And yeah, some de-spaghettification would be nice.  Certainly before adding
> more logic.
> 
> Martin, should we take out the early zone reclaim logic?  It's all
> unreachable at present anyway.
> 
...yeah just like sys_set_zone_reclaim.  was it intended to be added as
a system call?

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
