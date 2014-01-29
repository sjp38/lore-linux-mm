Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id A45356B0036
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 03:13:58 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so1466461pbb.35
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 00:13:58 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id sz7si1629705pab.145.2014.01.29.00.13.57
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 00:13:57 -0800 (PST)
Date: Wed, 29 Jan 2014 16:13:52 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: slub: fix page->_count corruption (again)
Message-ID: <20140129081352.GA20914@localhost>
References: <20140128231722.E7387E6B@viggo.jf.intel.com>
 <20140128152956.d5659f56ae279856731a1ac5@linux-foundation.org>
 <52E842CF.7090102@sr71.net>
 <20140129064350.GA20252@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140129064350.GA20252@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, pshelar@nicira.com

Hi Dave,

> > Fengguang, could you run a set of tests for the top patch in this branch
> > to see if we'd be giving much up by axing the code?
> > 
> > 	https://github.com/hansendc/linux/tree/slub-nocmpxchg-for-Fengguang-20140128
> 
> Sure, I've queued tests for the branch. Will report back after 1-2
> days.

btw, just a tip, it would normally cost half time if the branch is
based directly on a mainline (RC) release, eg. v3.13, v3.13-rcX.
Because to evaluate a branch, we need to test&compare its BASE and
HEAD. If the BASE is v3.* kernels, the test infrastructure will very
likely have tested it.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
