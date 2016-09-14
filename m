Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5929B6B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 05:49:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g202so17972076pfb.3
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 02:49:26 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m8si14985507pfi.128.2016.09.14.02.49.24
        for <linux-mm@kvack.org>;
        Wed, 14 Sep 2016 02:49:24 -0700 (PDT)
Date: Wed, 14 Sep 2016 10:49:02 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [kernel-hardening] [RFC PATCH v2 0/3] Add support for eXclusive
 Page Frame Ownership (XPFO)
Message-ID: <20160914094902.GA14330@leverpostej>
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20160914093634.GB13121@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914093634.GB13121@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-x86_64@vger.kernel.org, juerg.haefliger@hpe.com, vpk@cs.columbia.edu

On Wed, Sep 14, 2016 at 10:36:34AM +0100, Mark Rutland wrote:
> On Wed, Sep 14, 2016 at 09:18:58AM +0200, Juerg Haefliger wrote:
> > This patch series adds support for XPFO which protects against 'ret2dir'
> > kernel attacks. The basic idea is to enforce exclusive ownership of page
> > frames by either the kernel or userspace, unless explicitly requested by
> > the kernel. Whenever a page destined for userspace is allocated, it is
> > unmapped from physmap (the kernel's page table). When such a page is
> > reclaimed from userspace, it is mapped back to physmap.

> > Reference paper by the original patch authors:
> >   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf

> For both arm64 and x86_64, DEBUG_RODATA is mandatory (or soon to be so).
> Assuming that implies a lack of execute permission for x86_64, that
> should provide a similar level of protection against erroneously
> branching to addresses in the linear map, without the complexity and
> overhead of mapping/unmapping pages.
> 
> So to me it looks like this approach may only be useful for
> architectures without page-granular execute permission controls.
> 
> Is this also intended to protect against erroneous *data* accesses to
> the linear map?

Now that I read the paper more carefully, I can see that this is the
case, and this does catch issues which DEBUG_RODATA cannot.

Apologies for the noise.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
