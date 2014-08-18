Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id F24886B0035
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 17:48:22 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so8588244pac.31
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 14:48:22 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ff2si23706938pad.186.2014.08.18.14.48.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 18 Aug 2014 14:48:21 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so8391771pad.24
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 14:48:19 -0700 (PDT)
Date: Mon, 18 Aug 2014 14:48:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] memory-hotplug: add sysfs zones_online_to attribute
In-Reply-To: <53EAE534.8030303@huawei.com>
Message-ID: <alpine.DEB.2.02.1408181447260.4796@chino.kir.corp.google.com>
References: <1407902811-4873-1-git-send-email-zhenzhang.zhang@huawei.com> <53EAE534.8030303@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, toshi.kani@hp.com, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, wangnan0@huawei.com, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Wed, 13 Aug 2014, Zhang Zhen wrote:

> Currently memory-hotplug has two limits:
> 1. If the memory block is in ZONE_NORMAL, you can change it to
> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
> 2. If the memory block is in ZONE_MOVABLE, you can change it to
> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
> 
> With this patch, we can easy to know a memory block can be onlined to
> which zone, and don't need to know the above two limits.
> 
> Updated the related Documentation.
> 
> Change v1 -> v2:
> - optimize the implementation following Dave Hansen's suggestion
> 
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>

linux-next build failure:

drivers/built-in.o: In function `show_zones_online_to':
memory.c:(.text+0x13ee09): undefined reference to `test_pages_in_a_zone'

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
