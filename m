Date: Thu, 22 Jan 2004 18:26:17 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Can a page be HighMem without having the HighMem flag set?
Message-ID: <20040123022617.GY1016@holomorphy.com>
References: <1074824487.12774.185.camel@laptop-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1074824487.12774.185.camel@laptop-linux>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@users.sourceforge.net>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2004 at 03:26:53PM +1300, Nigel Cunningham wrote:
> I guess the subject says it all, but I'll give more detail:
> I'm working on Suspend on a 8 cpu ("8 way"?) SMP box at OSDL, which has
> something in excess of 4GB, but I'm only using 4 at the moment:
> Warning only 4GB will be used.
> Use a PAE enabled kernel.
> 3200MB HIGHMEM available.
> 896MB LOWMEM available.
> When suspending, I am seeing pages that don't have the HighMem flag set,
> but for which page_address returns zero.
> I looked at kmap, and noticed that it tests for page <
> highmem_start_page; I guess this is the way to do it?

You have found a bug. Could you chase down the inconsistency please?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
