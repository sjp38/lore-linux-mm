Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 810396B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 05:49:45 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ne4so6890652lbc.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 02:49:45 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id p72si9937823wmb.86.2016.06.01.02.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 02:49:44 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id z87so21731296wmh.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 02:49:44 -0700 (PDT)
Date: Wed, 1 Jun 2016 11:49:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiBbUEFUQ0hdIHJldXNp?=
 =?utf-8?Q?ng_of_mapping_page_supplies_a_way_for_file_page_allocation_und?=
 =?utf-8?Q?er_low_memory_due_to_pagecache_over_size_and_is_controlled_by_?=
 =?utf-8?Q?sysctl_parameters=2E_it_is_used_only_for_rw_page_allocatio?=
 =?utf-8?Q?n?= rather than fault or readahead allocation. it is like...
Message-ID: <20160601094942.GJ26601@dhcp22.suse.cz>
References: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
 <20160531093631.GH26128@dhcp22.suse.cz>
 <AE94847B1D9E864B8593BD8051012AF36D70EA02@SZXEML505-MBS.china.huawei.com>
 <20160531140354.GM26128@dhcp22.suse.cz>
 <ea553117-3735-fccb-0e7a-e289633cdd9f@huawei.com>
 <20160601081820.GG26601@dhcp22.suse.cz>
 <3b343dc4-a27b-9ed9-a1fd-e8a773352508@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3b343dc4-a27b-9ed9-a1fd-e8a773352508@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhouxiyu <zhouxiyu@huawei.com>, "wanghaijun (E)" <wanghaijun5@huawei.com>, "Yuchao (T)" <yuchao0@huawei.com>

On Wed 01-06-16 17:06:09, zhouxianrong wrote:
> > Why would you want to reuse a page about which you have no idea about
> > its age compared to the LRU pages which would be mostly clean as well?
> > I mean this needs a deep justification!
> 
> reusing could not reuse page with page_mapcount > 0; it only reuse
> a pure file page without mmap. only file pages producted by rw
> syscall can be reuse; so no AF consideration for it and just use
> active/inactive flag to distinguish.

I am sorry but I do not follow.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
