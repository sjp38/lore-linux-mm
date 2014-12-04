Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC016B0073
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 15:28:13 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id hn15so15334550igb.3
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 12:28:12 -0800 (PST)
Received: from resqmta-po-12v.sys.comcast.net ([2001:558:fe16:19:250:56ff:feb0:855])
        by mx.google.com with ESMTPS id w141si18701015iod.99.2014.12.04.12.28.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 12:28:12 -0800 (PST)
Date: Thu, 4 Dec 2014 14:28:10 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
In-Reply-To: <5480BFAA.2020106@ixiacom.com>
Message-ID: <alpine.DEB.2.11.1412041426230.14577@gentwo.org>
References: <547E3E57.3040908@ixiacom.com> <20141204175713.GE2995@htj.dyndns.org> <5480BFAA.2020106@ixiacom.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonard Crestez <lcrestez@ixiacom.com>
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sorin Dumitru <sdumitru@ixiacom.com>

On Thu, 4 Dec 2014, Leonard Crestez wrote:

> Yes, we are actually experiencing issues with this. We create lots of virtual
> net_devices and routes, which means lots of percpu counters/pointers. In particular
> we are getting worse performance than in older kernels because the net_device refcnt
> is now a percpu counter. We could turn that back into a single integer but this
> would negate an upstream optimization.

Well this is not a common use case and that is not what the per cpu
allocator was designed for. There is bound to be signifcant fragmentation
with the current design. The design was for rare allocations when
structures are initialized.

> Having a "properly scalable" percpu allocator would be quite nice indeed.

I guess we would be looking at a redesign of the allocator then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
