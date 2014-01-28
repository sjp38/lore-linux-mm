Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id A71DF6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 18:52:56 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so1009344pbc.18
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:52:56 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id fl7si278642pad.142.2014.01.28.15.52.50
        for <linux-mm@kvack.org>;
        Tue, 28 Jan 2014 15:52:50 -0800 (PST)
Message-ID: <52E842CF.7090102@sr71.net>
Date: Tue, 28 Jan 2014 15:52:47 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: slub: fix page->_count corruption (again)
References: <20140128231722.E7387E6B@viggo.jf.intel.com> <20140128152956.d5659f56ae279856731a1ac5@linux-foundation.org>
In-Reply-To: <20140128152956.d5659f56ae279856731a1ac5@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, pshelar@nicira.com, Wu Fengguang <fengguang.wu@intel.com>

On 01/28/2014 03:29 PM, Andrew Morton wrote:
> On Tue, 28 Jan 2014 15:17:22 -0800 Dave Hansen <dave@sr71.net> wrote:
> This code is borderline insane.

No argument here.

> Yes, struct page is special and it's worth spending time and doing
> weird things to optimise it.  But sheesh.
> 
> An alternative is to make that cmpxchg quietly go away.  Is it more
> trouble than it is worth?

It has measurable performance benefits, and the benefits go up as the
cost of en/disabling interrupts goes up (like if it takes you a hypercall).

Fengguang, could you run a set of tests for the top patch in this branch
to see if we'd be giving much up by axing the code?

	https://github.com/hansendc/linux/tree/slub-nocmpxchg-for-Fengguang-20140128

I was talking with one of the distros about turning it off as well.
They mentioned that they saw a few performance regressions when it was
turned off.  I'll share details when I get them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
