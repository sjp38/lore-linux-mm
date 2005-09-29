Date: Thu, 29 Sep 2005 16:11:18 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] earlier allocation of order 0 pages from pcp in
 __alloc_pages
Message-Id: <20050929161118.27f9f1eb.akpm@osdl.org>
In-Reply-To: <719460000.1128034108@[10.10.2.4]>
References: <20050929150155.A15646@unix-os.sc.intel.com>
	<719460000.1128034108@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: rohit.seth@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Hicks <mort@sgi.com>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@mbligh.org> wrote:
>
> It looks like we're now dropping into direct reclaim as the first thing
> in __alloc_pages before even trying to kick off kswapd. When the hell
> did that start? Or is that only meant to trigger if we're already below
> the low watermark level?

That's all the numa goop which Martin Hicks added.  It's all disabled if
z->reclaim_pages is zero (it is).  However we could be testing that flag a
bit earlier, I think.

And yeah, some de-spaghettification would be nice.  Certainly before adding
more logic.

Martin, should we take out the early zone reclaim logic?  It's all
unreachable at present anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
