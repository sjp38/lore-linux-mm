Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0CE6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 03:30:27 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so1424608pdj.19
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 00:30:27 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id mj6si1677121pab.188.2014.01.29.00.30.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 00:30:26 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so1478170pab.6
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 00:30:26 -0800 (PST)
Date: Wed, 29 Jan 2014 00:30:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: slub: fix page->_count corruption (again)
In-Reply-To: <52E842CF.7090102@sr71.net>
Message-ID: <alpine.DEB.2.02.1401290029120.12210@chino.kir.corp.google.com>
References: <20140128231722.E7387E6B@viggo.jf.intel.com> <20140128152956.d5659f56ae279856731a1ac5@linux-foundation.org> <52E842CF.7090102@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, pshelar@nicira.com, Wu Fengguang <fengguang.wu@intel.com>

On Tue, 28 Jan 2014, Dave Hansen wrote:

> It has measurable performance benefits, and the benefits go up as the
> cost of en/disabling interrupts goes up (like if it takes you a hypercall).
> 
> Fengguang, could you run a set of tests for the top patch in this branch
> to see if we'd be giving much up by axing the code?
> 
> 	https://github.com/hansendc/linux/tree/slub-nocmpxchg-for-Fengguang-20140128
> 
> I was talking with one of the distros about turning it off as well.
> They mentioned that they saw a few performance regressions when it was
> turned off.  I'll share details when I get them.
> 

FWIW, I've compared netperf TCP_RR on all machine types I have available 
with and without cmpxchg_double and I've never measured a regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
