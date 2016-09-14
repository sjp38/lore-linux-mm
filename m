Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8D6F6B0253
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:33:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id mi5so30148494pab.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:33:09 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id bx7si5029664pac.110.2016.09.14.07.33.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 07:33:09 -0700 (PDT)
Subject: Re: [kernel-hardening] [RFC PATCH v2 2/3] xpfo: Only put previous
 userspace pages into the hot cache
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-3-juerg.haefliger@hpe.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D95FA3.3030103@intel.com>
Date: Wed, 14 Sep 2016 07:33:07 -0700
MIME-Version: 1.0
In-Reply-To: <20160914071901.8127-3-juerg.haefliger@hpe.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-x86_64@vger.kernel.org
Cc: juerg.haefliger@hpe.com, vpk@cs.columbia.edu

On 09/14/2016 12:19 AM, Juerg Haefliger wrote:
> Allocating a page to userspace that was previously allocated to the
> kernel requires an expensive TLB shootdown. To minimize this, we only
> put non-kernel pages into the hot cache to favor their allocation.

Hi, I had some questions about this the last time you posted it.  Maybe
you want to address them now.

--

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
