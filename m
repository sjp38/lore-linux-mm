Received: by rv-out-0910.google.com with SMTP id f1so2845573rvb.26
        for <linux-mm@kvack.org>; Mon, 17 Mar 2008 00:53:43 -0700 (PDT)
Message-ID: <86802c440803170053n32a1c918h2ff2a32abef44050@mail.gmail.com>
Date: Mon, 17 Mar 2008 00:53:43 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] [11/18] Fix alignment bug in bootmem allocator
In-Reply-To: <20080317074146.GG27015@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080317258.659191058@firstfloor.org>
	 <20080317015825.0C0171B41E0@basil.firstfloor.org>
	 <86802c440803161919h20ed9f78k6e3798ef56668638@mail.gmail.com>
	 <20080317070208.GC27015@one.firstfloor.org>
	 <86802c440803170017r622114bdpede8625d1a8ff585@mail.gmail.com>
	 <86802c440803170031u75167e5m301f65049b6d62ff@mail.gmail.com>
	 <20080317074146.GG27015@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 12:41 AM, Andi Kleen <andi@firstfloor.org> wrote:
> > when node_boot_start is 512M alignment, and align is 1024M, offset
>  > could be 512M. it seems
>  > i = ALIGN(i, incr) need to do sth with offset...
>
>  It's possible that there are better fixes for this, but at least
>  my simple patch seems to work here. I admit I was banging my
>  head against this for some time and when I did the fix I just
>  wanted the bug to go away and didn't really go for subtleness.
>
>  The bootmem allocator is quite spaghetti in fact, it could
>  really need some general clean up (although it's' not quite
>  as bad yet as page_alloc.c)

i = ALIGN(i+offset, incr) - offset;

also the one in fail_block...

only happen when align is large than alignment of node_boot_start.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
