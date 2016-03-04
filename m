Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7764F6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 15:04:43 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id n186so5904692wmn.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 12:04:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b65si689576wmd.40.2016.03.04.12.04.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 12:04:42 -0800 (PST)
Date: Fri, 4 Mar 2016 12:04:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-Id: <20160304120439.a38a15e0fe5b989fe5b8edfc@linux-foundation.org>
In-Reply-To: <CAAmzW4NwhSKw432qw0Ry+gi=yGpRU-MtC-zQGL27o+XEawLKrg@mail.gmail.com>
References: <1456448282-897-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1456448282-897-2-git-send-email-iamjoonsoo.kim@lge.com>
	<56D71BB2.5060503@suse.cz>
	<CAAmzW4NwhSKw432qw0Ry+gi=yGpRU-MtC-zQGL27o+XEawLKrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 3 Mar 2016 16:43:49 +0900 Joonsoo Kim <js1304@gmail.com> wrote:

> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >
> >> +config DEBUG_PAGE_REF
> >> +       bool "Enable tracepoint to track down page reference manipulation"
> >> +       depends on DEBUG_KERNEL
> >> +       depends on TRACEPOINTS
> >> +       ---help---
> >> +         This is the feature to add tracepoint for tracking down page
> >> reference
> >> +         manipulation. This tracking is useful to diagnosis functional
> >> failure
> >> +         due to migration failure caused by page reference mismatch. Be
> >
> >
> > OK.
> >
> >> +         careful to turn on this feature because it could bloat some
> >> kernel
> >> +         text. In my configuration, it bloats 30 KB. Although kernel text
> >> will
> >> +         be bloated, there would be no runtime performance overhead if
> >> +         tracepoint isn't enabled thanks to jump label.
> >
> >
> > I would just write something like:
> >
> > Enabling this feature adds about 30 KB to the kernel code, but runtime
> > performance overhead is virtually none until the tracepoints are actually
> > enabled.
> 
> Okay, better!
> Andrew, do you want fixup patch from me or could you simply handle it?
> 

This?

--- a/mm/Kconfig.debug~mm-page_ref-add-tracepoint-to-track-down-page-reference-manipulation-fix-3-fix
+++ a/mm/Kconfig.debug
@@ -82,10 +82,9 @@ config DEBUG_PAGE_REF
 	depends on DEBUG_KERNEL
 	depends on TRACEPOINTS
 	---help---
-	  This is the feature to add tracepoint for tracking down page reference
-	  manipulation. This tracking is useful to diagnosis functional failure
-	  due to migration failure caused by page reference mismatch. Be
-	  careful to turn on this feature because it could bloat some kernel
-	  text. In my configuration, it bloats 30 KB. Although kernel text will
-	  be bloated, there would be no runtime performance overhead if
-	  tracepoint isn't enabled thanks to jump label.
+	  This is a feature to add tracepoint for tracking down page reference
+	  manipulation. This tracking is useful to diagnose functional failure
+	  due to migration failures caused by page reference mismatches.  Be
+	  careful when enabling this feature because it adds about 30 KB to the
+	  kernel code.  However the runtime performance overhead is virtually
+	  nil until the tracepoints are actually enabled.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
