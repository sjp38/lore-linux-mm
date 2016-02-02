Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 221356B0253
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 18:04:37 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so1985838pfd.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 15:04:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3si4536877pfo.227.2016.02.02.15.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 15:04:36 -0800 (PST)
Date: Tue, 2 Feb 2016 15:04:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
Message-Id: <20160202150435.60076ce1d603a99c17c08edf@linux-foundation.org>
In-Reply-To: <56B12FBE.3070909@de.ibm.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
	<1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
	<alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com>
	<56A9E3D1.3090001@de.ibm.com>
	<alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1602021351290.4977@chino.kir.corp.google.com>
	<56B12560.4010201@de.ibm.com>
	<20160202142157.1bfc6f81807faaa026957917@linux-foundation.org>
	<56B12FBE.3070909@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk

On Tue, 2 Feb 2016 23:37:50 +0100 Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> On 02/02/2016 11:21 PM, Andrew Morton wrote:
> > On Tue, 2 Feb 2016 22:53:36 +0100 Christian Borntraeger <borntraeger@de.ibm.com> wrote:
> > 
> >>>> I don't think we should have a CONFIG_DEBUG_PAGEALLOC that does some stuff 
> >>>> and then a commandline parameter or CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT 
> >>>> to enable more stuff.  It should either be all enabled by the commandline 
> >>>> (or config option) or split into a separate entity.  
> >>>> CONFIG_DEBUG_PAGEALLOC_LIGHT and CONFIG_DEBUG_PAGEALLOC would be fine, but 
> >>>> the current state is very confusing about what is being done and what 
> >>>> isn't.
> >>>>
> >>>
> >>> Ping?
> >>>
> >> https://lkml.org/lkml/2016/1/29/266 
> > 
> > That's already in linux-next so I can't apply it.
> > 
> > Well, I can, but it's a hassle.  What's happening here?
> 
> I pushed it on my tree for kbuild testing purposes some days ago. 
> Will drop so that it can go via mm.

There are other patches that I haven't merged because they were already
in -next.  In fact I think I dropped them because they later popped up
in -next.

Some or all of:

lib-spinlock_debugc-prevent-an-infinite-recursive-cycle-in-spin_dump.patch
mm-provide-debug_pagealloc_enabled-without-config_debug_pagealloc.patch
x86-query-dynamic-debug_pagealloc-setting.patch
s390-query-dynamic-debug_pagealloc-setting.patch
mm-provide-debug_pagealloc_enabled-without-config_debug_pagealloc.patch
x86-query-dynamic-debug_pagealloc-setting.patch
s390-query-dynamic-debug_pagealloc-setting.patch

So please resend everything which you think is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
