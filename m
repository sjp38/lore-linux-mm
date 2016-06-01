Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07BA76B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 04:18:23 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id j12so5767946lbo.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 01:18:22 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id wx8si55491256wjb.149.2016.06.01.01.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 01:18:21 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id a136so169168522wme.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 01:18:21 -0700 (PDT)
Date: Wed, 1 Jun 2016 10:18:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiBbUEFUQ0hdIHJldXNp?=
 =?utf-8?Q?ng_of_mapping_page_supplies_a_way_for_file_page_allocation_und?=
 =?utf-8?Q?er_low_memory_due_to_pagecache_over_size_and_is_controlled_by_?=
 =?utf-8?Q?sysctl_parameters=2E_it_is_used_only_for_rw_page_allocatio?=
 =?utf-8?Q?n?= rather than fault or readahead allocation. it is like...
Message-ID: <20160601081820.GG26601@dhcp22.suse.cz>
References: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
 <20160531093631.GH26128@dhcp22.suse.cz>
 <AE94847B1D9E864B8593BD8051012AF36D70EA02@SZXEML505-MBS.china.huawei.com>
 <20160531140354.GM26128@dhcp22.suse.cz>
 <ea553117-3735-fccb-0e7a-e289633cdd9f@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea553117-3735-fccb-0e7a-e289633cdd9f@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhouxiyu <zhouxiyu@huawei.com>, "wanghaijun (E)" <wanghaijun5@huawei.com>, "Yuchao (T)" <yuchao0@huawei.com>

On Wed 01-06-16 09:52:45, zhouxianrong wrote:
> >> A page suitable for reusing within mapping is
> >> 1. clean
> >> 2. map count is zero
> >> 3. whose mapping is evictable
> >
> > Those pages are trivially reclaimable so why should we tag them in a
> > special way?
> yes, those pages can be reclaimed by reclaim procedure. i think in low memory
> case for a process that doing file rw directly-reusing-mapping-page may be
> a choice than alloc_page just like directly reclaim. alloc_page could failed return
> due to gfp and watermark in low memory. for reusing-mapping-page procedure quickly
> select a page that is be reused so introduce a tag for this purpose.

Why would you want to reuse a page about which you have no idea about
its age compared to the LRU pages which would be mostly clean as well?
I mean this needs a deep justification!

> > So is this a form of a page cache limit to trigger the reclaim earlier
> > than on the global memory pressure?

> my thinking is that page cache limit trigger reuse-mapping-page. the
> limit is earlier than on the global memory pressure.
> reuse-mapping-page can suppress increment of page cache size and big page cache size
> is one reason of low memory and fragment.

But why would you want to limit the amount of the page cache in the
first place when it should be trivially reclaimable most of the time?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
