Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B2DDC6B003C
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 13:59:53 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so4400215pab.20
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 10:59:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qp1si6749890pac.31.2014.07.24.10.59.52
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 10:59:52 -0700 (PDT)
Message-ID: <53D14997.7090106@intel.com>
Date: Thu, 24 Jul 2014 10:59:51 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: add sysfs zone_index attribute
References: <1406187138-27911-1-git-send-email-zhenzhang.zhang@huawei.com> <53D0B8B6.8040104@huawei.com>
In-Reply-To: <53D0B8B6.8040104@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>, mingo@redhat.com, Yinghai Lu <yinghai@kernel.org>, mgorman@suse.de, akpm@linux-foundation.org, zhangyanfei@cn.fujitsu.com
Cc: wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 07/24/2014 12:41 AM, Zhang Zhen wrote:
> Currently memory-hotplug has two limits:
> 1. If the memory block is in ZONE_NORMAL, you can change it to
> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
> 2. If the memory block is in ZONE_MOVABLE, you can change it to
> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
> 
> Without this patch, we don't know which zone a memory block is in.
> So we don't know which memory block is adjacent to ZONE_MOVABLE or
> ZONE_NORMAL.
> 
> On the other hand, with this patch, we can easy to know newly added
> memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA, for x86_32,
> ZONE_HIGHMEM).

A section can contain more than one zone.  This interface will lie about
such sections, which is quite unfortunate.

I'd really much rather see an interface that has a section itself
enumerate to which zones it may be changed.  The way you have it now,
any user has to know the rules that you've laid out above.  If the
kernel changed those restrictions, we'd have to teach every application
about the change in restrictions.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
