Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 653E56B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 12:08:21 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so12609074vcb.38
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:08:21 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.232])
        by mx.google.com with ESMTP id em7si10932370vdb.53.2014.05.28.09.08.19
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 09:08:20 -0700 (PDT)
Date: Wed, 28 May 2014 12:08:17 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140528120817.71921d6a@gandalf.local.home>
In-Reply-To: <CAFLxGvyV2Upn7+uTtScu2_LGazy9L+HU9DWEC==0qyZphCrauA@mail.gmail.com>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CAFLxGvyV2Upn7+uTtScu2_LGazy9L+HU9DWEC==0qyZphCrauA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>

On Wed, 28 May 2014 17:43:50 +0200
Richard Weinberger <richard.weinberger@gmail.com> wrote:


> > diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
> > index 8de6d9cf3b95..678205195ae1 100644
> > --- a/arch/x86/include/asm/page_64_types.h
> > +++ b/arch/x86/include/asm/page_64_types.h
> > @@ -1,7 +1,7 @@
> >  #ifndef _ASM_X86_PAGE_64_DEFS_H
> >  #define _ASM_X86_PAGE_64_DEFS_H
> >
> > -#define THREAD_SIZE_ORDER      1
> > +#define THREAD_SIZE_ORDER      2
> >  #define THREAD_SIZE  (PAGE_SIZE << THREAD_SIZE_ORDER)
> >  #define CURRENT_MASK (~(THREAD_SIZE - 1))
> 
> Do you have any numbers of the performance impact of this?
> 

What performance impact are you looking for? Now if the system is short
on memory, it would probably cause issues in creating tasks. But other
than that, I'm not sure what you are looking for.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
