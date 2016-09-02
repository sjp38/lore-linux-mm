Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7166B0069
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 16:39:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g202so145375305pfb.3
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 13:39:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b64si13196217pfa.51.2016.09.02.13.39.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Sep 2016 13:39:23 -0700 (PDT)
Subject: Re: [RFC PATCH v2 2/3] xpfo: Only put previous userspace pages into
 the hot cache
References: <1456496467-14247-1-git-send-email-juerg.haefliger@hpe.com>
 <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160902113909.32631-3-juerg.haefliger@hpe.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57C9E37A.9070805@intel.com>
Date: Fri, 2 Sep 2016 13:39:22 -0700
MIME-Version: 1.0
In-Reply-To: <20160902113909.32631-3-juerg.haefliger@hpe.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@hpe.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu

On 09/02/2016 04:39 AM, Juerg Haefliger wrote:
> Allocating a page to userspace that was previously allocated to the
> kernel requires an expensive TLB shootdown. To minimize this, we only
> put non-kernel pages into the hot cache to favor their allocation.

But kernel allocations do allocate from these pools, right?  Does this
just mean that kernel allocations usually have to pay the penalty to
convert a page?

So, what's the logic here?  You're assuming that order-0 kernel
allocations are more rare than allocations for userspace?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
