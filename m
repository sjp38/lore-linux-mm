Received: by rv-out-0910.google.com with SMTP id f1so2842005rvb.26
        for <linux-mm@kvack.org>; Mon, 17 Mar 2008 00:31:30 -0700 (PDT)
Message-ID: <86802c440803170031u75167e5m301f65049b6d62ff@mail.gmail.com>
Date: Mon, 17 Mar 2008 00:31:29 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] [11/18] Fix alignment bug in bootmem allocator
In-Reply-To: <86802c440803170017r622114bdpede8625d1a8ff585@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080317258.659191058@firstfloor.org>
	 <20080317015825.0C0171B41E0@basil.firstfloor.org>
	 <86802c440803161919h20ed9f78k6e3798ef56668638@mail.gmail.com>
	 <20080317070208.GC27015@one.firstfloor.org>
	 <86802c440803170017r622114bdpede8625d1a8ff585@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 12:17 AM, Yinghai Lu <yhlu.kernel@gmail.com> wrote:
>
> On Mon, Mar 17, 2008 at 12:02 AM, Andi Kleen <andi@firstfloor.org> wrote:
>  > > node_boot_start is not page aligned?
>  >
>  >  It is, but it is not necessarily GB aligned and without this
>  >  change sometimes alloc_bootmem when requesting GB alignment
>  >  doesn't return GB aligned memory. This was a nasty problem
>  >  that took some time to track down.
>
>  or preferred has some problem?
>
>
>  preferred = PFN_DOWN(ALIGN(preferred, align)) + offset;
>

when node_boot_start is 512M alignment, and align is 1024M, offset
could be 512M. it seems
i = ALIGN(i, incr) need to do sth with offset...

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
