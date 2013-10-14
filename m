Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5CACE6B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 10:43:28 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so7539828pab.20
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 07:43:27 -0700 (PDT)
Message-ID: <525C0307.7020802@ti.com>
Date: Mon, 14 Oct 2013 10:43:19 -0400
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [RFC 09/23] mm/init: Use memblock apis for early memory allocations
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com> <1381615146-20342-10-git-send-email-santosh.shilimkar@ti.com> <20131013195406.GC18075@htj.dyndns.org>
In-Reply-To: <20131013195406.GC18075@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: yinghai@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Andrew Morton <akpm@linux-foundation.org>

On Sunday 13 October 2013 03:54 PM, Tejun Heo wrote:
> On Sat, Oct 12, 2013 at 05:58:52PM -0400, Santosh Shilimkar wrote:
>> Switch to memblock interfaces for early memory allocator
> 
> When posting actual (non-RFC) patches later, please cc the maintainers
> of the target subsystem and briefly explain why the new interface is
> needed and that this doesn't change visible behavior.
> 
Sure. Thanks a lot for quick response on the series. I will give another
week or so to see if there are more comments and then start addressing
comments in next version.

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
