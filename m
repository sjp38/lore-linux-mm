Date: Tue, 14 Sep 2004 07:13:15 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Do not mark being-truncated-pages as cache hot
Message-ID: <20040914101315.GC23935@logos.cnet>
References: <20040913215753.GA23119@logos.cnet> <66880000.1095120205@flay> <20040913231940.GC23588@logos.cnet> <20040913182148.48d36fdf.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040913182148.48d36fdf.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: mbligh@aracnet.com, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2004 at 06:21:48PM -0700, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> > So when we hit the high watermark, "hotter" pages are sent back to SLAB. 
> 
> That would be a bug.
> 
> free_hot_cold_page() sticks the being-freed page at ->next, while
> free_pages_bulk() frees pages at ->prev.   Looks OK? 

Yes looks OK, I misinterpreted.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
