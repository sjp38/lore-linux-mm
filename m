Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 649DF6B0005
	for <linux-mm@kvack.org>; Sun,  6 Mar 2016 23:20:19 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id ig19so10518008igb.1
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 20:20:19 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w6si10406519igz.60.2016.03.06.20.20.17
        for <linux-mm@kvack.org>;
        Sun, 06 Mar 2016 20:20:18 -0800 (PST)
Date: Mon, 7 Mar 2016 13:20:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v4 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160307042054.GA24602@js1304-P5Q-DELUXE>
References: <1456448282-897-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1456448282-897-2-git-send-email-iamjoonsoo.kim@lge.com>
 <56D71BB2.5060503@suse.cz>
 <CAAmzW4NwhSKw432qw0Ry+gi=yGpRU-MtC-zQGL27o+XEawLKrg@mail.gmail.com>
 <20160304120439.a38a15e0fe5b989fe5b8edfc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160304120439.a38a15e0fe5b989fe5b8edfc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri, Mar 04, 2016 at 12:04:39PM -0800, Andrew Morton wrote:
> On Thu, 3 Mar 2016 16:43:49 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
> 
> > > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > >
> > >> +config DEBUG_PAGE_REF
> > >> +       bool "Enable tracepoint to track down page reference manipulation"
> > >> +       depends on DEBUG_KERNEL
> > >> +       depends on TRACEPOINTS
> > >> +       ---help---
> > >> +         This is the feature to add tracepoint for tracking down page
> > >> reference
> > >> +         manipulation. This tracking is useful to diagnosis functional
> > >> failure
> > >> +         due to migration failure caused by page reference mismatch. Be
> > >
> > >
> > > OK.
> > >
> > >> +         careful to turn on this feature because it could bloat some
> > >> kernel
> > >> +         text. In my configuration, it bloats 30 KB. Although kernel text
> > >> will
> > >> +         be bloated, there would be no runtime performance overhead if
> > >> +         tracepoint isn't enabled thanks to jump label.
> > >
> > >
> > > I would just write something like:
> > >
> > > Enabling this feature adds about 30 KB to the kernel code, but runtime
> > > performance overhead is virtually none until the tracepoints are actually
> > > enabled.
> > 
> > Okay, better!
> > Andrew, do you want fixup patch from me or could you simply handle it?
> > 
> 
> This?

Yep!

Thanks!

> 
> --- a/mm/Kconfig.debug~mm-page_ref-add-tracepoint-to-track-down-page-reference-manipulation-fix-3-fix
> +++ a/mm/Kconfig.debug
> @@ -82,10 +82,9 @@ config DEBUG_PAGE_REF
>  	depends on DEBUG_KERNEL
>  	depends on TRACEPOINTS
>  	---help---
> -	  This is the feature to add tracepoint for tracking down page reference
> -	  manipulation. This tracking is useful to diagnosis functional failure
> -	  due to migration failure caused by page reference mismatch. Be
> -	  careful to turn on this feature because it could bloat some kernel
> -	  text. In my configuration, it bloats 30 KB. Although kernel text will
> -	  be bloated, there would be no runtime performance overhead if
> -	  tracepoint isn't enabled thanks to jump label.
> +	  This is a feature to add tracepoint for tracking down page reference
> +	  manipulation. This tracking is useful to diagnose functional failure
> +	  due to migration failures caused by page reference mismatches.  Be
> +	  careful when enabling this feature because it adds about 30 KB to the
> +	  kernel code.  However the runtime performance overhead is virtually
> +	  nil until the tracepoints are actually enabled.
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
