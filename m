Date: Mon, 13 Sep 2004 18:21:48 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Do not mark being-truncated-pages as cache hot
Message-Id: <20040913182148.48d36fdf.akpm@osdl.org>
In-Reply-To: <20040913231940.GC23588@logos.cnet>
References: <20040913215753.GA23119@logos.cnet>
	<66880000.1095120205@flay>
	<20040913231940.GC23588@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: mbligh@aracnet.com, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> So when we hit the high watermark, "hotter" pages are sent back to SLAB. 

That would be a bug.

free_hot_cold_page() sticks the being-freed page at ->next, while
free_pages_bulk() frees pages at ->prev.   Looks OK? 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
