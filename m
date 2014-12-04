Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3942A6B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 12:57:18 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id 79so8232858ykr.0
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 09:57:18 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id g75si32067026qge.83.2014.12.04.09.57.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 09:57:17 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id i17so13182565qcy.21
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 09:57:16 -0800 (PST)
Date: Thu, 4 Dec 2014 12:57:13 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
Message-ID: <20141204175713.GE2995@htj.dyndns.org>
References: <547E3E57.3040908@ixiacom.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <547E3E57.3040908@ixiacom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonard Crestez <lcrestez@ixiacom.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Sorin Dumitru <sdumitru@ixiacom.com>

Hello,

On Wed, Dec 03, 2014 at 12:33:59AM +0200, Leonard Crestez wrote:
> It seems that free_percpu performance is very bad when working with small 
> objects. The easiest way to reproduce this is to allocate and then free a large 
> number of percpu int counters in order. Small objects (reference counters and 
> pointers) are common users of alloc_percpu and I think this should be fast.
> This particular issue can be encountered with very large number of net_device
> structs.

Do you actually experience this with an actual workload?  The thing is
allocation has the same quadratic complexity.  If this is actually an
issue (which can definitely be the case), I'd much prefer implementing
a properly scalable area allocator than mucking with the current
implementation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
