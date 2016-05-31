Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D52516B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 10:03:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a136so44541655wme.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 07:03:57 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id y1si50863066wjm.132.2016.05.31.07.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 07:03:56 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q62so33086856wmg.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 07:03:56 -0700 (PDT)
Date: Tue, 31 May 2016 16:03:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiBbUEFUQ0hdIHJldXNp?=
 =?utf-8?Q?ng_of_mapping_page_supplies_a_way_for_file_page_allocation_und?=
 =?utf-8?Q?er_low_memory_due_to_pagecache_over_size_and_is_controlled_by_?=
 =?utf-8?Q?sysctl_parameters=2E_it_is_used_only_for_rw_page_allocatio?=
 =?utf-8?Q?n?= rather than fault or readahead allocation. it is like...
Message-ID: <20160531140354.GM26128@dhcp22.suse.cz>
References: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
 <20160531093631.GH26128@dhcp22.suse.cz>
 <AE94847B1D9E864B8593BD8051012AF36D70EA02@SZXEML505-MBS.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AE94847B1D9E864B8593BD8051012AF36D70EA02@SZXEML505-MBS.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhouxiyu <zhouxiyu@huawei.com>, "wanghaijun (E)" <wanghaijun5@huawei.com>, "Yuchao (T)" <yuchao0@huawei.com>

On Tue 31-05-16 13:35:37, zhouxianrong wrote:
> Hey :
> the consideration of this patch is that reusing mapping page
> rather than allocating a new page for page cache when system be
> placed in some states.  For lookup pages quickly add a new tag
> PAGECACHE_TAG_REUSE for radix tree which tag the pages that is
> suitable for reusing.
> 
> A page suitable for reusing within mapping is
> 1. clean
> 2. map count is zero
> 3. whose mapping is evictable

Those pages are trivially reclaimable so why should we tag them in a
special way?

[...]

> How to startup the functional
> 1. the system is under low memory state and there are fs rw operations
> 2. page cache size is get bigger over sysctl limit

So is this a form of a page cache limit to trigger the reclaim earlier
than on the global memory pressure?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
