Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EE09E828EB
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:31:11 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 65so50612377pff.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 13:31:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n1si38714708pap.199.2016.01.11.13.31.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 13:31:11 -0800 (PST)
Date: Mon, 11 Jan 2016 13:31:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: EXPORT_SYMBOL_GPL(find_vm_area);
Message-Id: <20160111133110.a9cb49cdbdb88c58a1352597@linux-foundation.org>
In-Reply-To: <5693A77E.4020809@linux.intel.com>
References: <1447247184-27939-1-git-send-email-sakari.ailus@linux.intel.com>
	<20151202162558.d0465f11746ff94114c5d987@linux-foundation.org>
	<5693A77E.4020809@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: linux-mm@kvack.org

On Mon, 11 Jan 2016 15:00:46 +0200 Sakari Ailus <sakari.ailus@linux.intel.com> wrote:

> Hi Andrew,
> 
> Andrew Morton wrote:
> > On Wed, 11 Nov 2015 15:06:24 +0200 Sakari Ailus <sakari.ailus@linux.intel.com> wrote:
> > 
> >> find_vm_area() is needed in implementing the DMA mapping API as a module.
> >> Device specific IOMMUs with associated DMA mapping implementations should be
> >> buildable as modules.
> >>
> >> ...
> >>
> >> --- a/mm/vmalloc.c
> >> +++ b/mm/vmalloc.c
> >> @@ -1416,6 +1416,7 @@ struct vm_struct *find_vm_area(const void *addr)
> >>  
> >>  	return NULL;
> >>  }
> >> +EXPORT_SYMBOL_GPL(find_vm_area);
> > 
> > Confused.  Who is setting CONFIG_HAS_DMA=m?
> > 
> 
> Apologies for the late reply --- CONFIG_HAS_DMA isn't configured as a
> module, but some devices are not DMA coherent even on x86. The existing
> x86 DMA mapping implementation doesn't quite work for those at the
> moment, and nothing prevents using another one (and as a module, in
> which case this patch is required).

hm, if you say so.

Please resend the patch sometime along with a much much more detailed
changelog?  If at all appropriate please cc the x86 maintainers so they
can understand why the current DMA mapping implementation is
inappropriate for whatever this requirement is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
