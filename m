Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C42B36B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 05:58:34 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w143so21314954oiw.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 02:58:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id r22si21492126otb.2.2016.06.01.02.58.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 02:58:34 -0700 (PDT)
Subject: =?UTF-8?Q?Re:_=e7=ad=94=e5=a4=8d:_[PATCH]_reusing_of_mapping_page_s?=
 =?UTF-8?Q?upplies_a_way_for_file_page_allocation_under_low_memory_due_to_pa?=
 =?UTF-8?Q?gecache_over_size_and_is_controlled_by_sysctl_parameters._it_is_u?=
 =?UTF-8?Q?sed_only_for_rw_page_allocation_rather_than_fault_or_readahead_al?=
 =?UTF-8?Q?location._it_is_like...?=
References: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
 <20160531093631.GH26128@dhcp22.suse.cz>
 <AE94847B1D9E864B8593BD8051012AF36D70EA02@SZXEML505-MBS.china.huawei.com>
 <20160531140354.GM26128@dhcp22.suse.cz>
 <ea553117-3735-fccb-0e7a-e289633cdd9f@huawei.com>
 <20160601081820.GG26601@dhcp22.suse.cz>
 <3b343dc4-a27b-9ed9-a1fd-e8a773352508@huawei.com>
 <20160601094942.GJ26601@dhcp22.suse.cz>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <a8366f6f-e6eb-8e59-b872-50fe30b74a03@huawei.com>
Date: Wed, 1 Jun 2016 17:56:13 +0800
MIME-Version: 1.0
In-Reply-To: <20160601094942.GJ26601@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhouxiyu <zhouxiyu@huawei.com>, "wanghaijun (E)" <wanghaijun5@huawei.com>, "Yuchao (T)" <yuchao0@huawei.com>

ok, the idea is not better, thank you

On 2016/6/1 17:49, Michal Hocko wrote:
> On Wed 01-06-16 17:06:09, zhouxianrong wrote:
>>> Why would you want to reuse a page about which you have no idea about
>>> its age compared to the LRU pages which would be mostly clean as well?
>>> I mean this needs a deep justification!
>>
>> reusing could not reuse page with page_mapcount > 0; it only reuse
>> a pure file page without mmap. only file pages producted by rw
>> syscall can be reuse; so no AF consideration for it and just use
>> active/inactive flag to distinguish.
>
> I am sorry but I do not follow.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
