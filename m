Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86611C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:57:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D92220693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:57:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D92220693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB9C66B0003; Tue, 16 Apr 2019 08:57:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6BE16B0006; Tue, 16 Apr 2019 08:57:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A32E26B0007; Tue, 16 Apr 2019 08:57:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9AC6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:57:17 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id v10so9798660oie.4
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 05:57:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=r4FAAc165g+WsCZKbB8bO8geNANYXmPPZMDe3iqdbFs=;
        b=J4OOD1oRS0O+TU+upBAQMGtXaV3TsdyTnevF9RhCU+Xy9jhjcBycX0Reh5Htpfa8Uw
         JjNemt/QJWEco8JhBgtZroeTOq6gdNg7kXSlqbhh5qC/GDG+Li8GHOoxVvfpW3jqwfoU
         G3h6ethRmpIdvQecSyNMrZdc1cth0whXB8cQ69Lk2XIO50WpL5Pth88WlX8EGJl1Zioe
         SYcZYoyjCqZhd2oZS2DZVNMTkHKwYFvqOu2JtMAuz/GpxZZsh75Ui4AAQ0/8lF1iQigy
         gRz+DU+D0/V9fvCM5L47camEmgWn38MGBDHpw+A2VwD5KzpgKHU8+c7xSwmMcZ36fUbK
         9NSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAW7wKXnCF0LgJDekpfnl4pnIM9ndDtnfYJ4Aof5sgWZxYfE7K4n
	Fcfg4xipAT0tFsuQCnKZSVX5zMecB45aV+UUy5/9z1dYh0Ib7pOzcsz/kmW+sKyglrQVW/aRwCG
	G9+3pC9HJouLmwGBkd7j7I77fcdT7CO2pfV2rla0kqCW+XQqkpbF9fSbiYGT6V6krPQ==
X-Received: by 2002:a05:6830:16d3:: with SMTP id l19mr48633627otr.92.1555419437174;
        Tue, 16 Apr 2019 05:57:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRDRPPsN4WrWvwsio/BMbd8lNYpLIgz062HCAgseClBKkthwx4FYdoIaCuRg/mIiGhCBKQ
X-Received: by 2002:a05:6830:16d3:: with SMTP id l19mr48633587otr.92.1555419436145;
        Tue, 16 Apr 2019 05:57:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555419436; cv=none;
        d=google.com; s=arc-20160816;
        b=XJMM/XuKUGEfM95Nrs/zLAp6NlZj4n0ClusImfbt4ZdEd5Qay2REIj1gu6KnotW+RE
         Et6UArnvedmwrq+xrANhi+dYC4JVttJaDEUEMA6qnyBcWf8CEIDYSwDzWPs8yq5G/3vw
         z79IGOOQd4jlXGA1OuScPzBICXEvYISoFg2IHXR4S4GRTiSFbLpA4FUGCZJLVijd7kjS
         5D5GWAEiPfT5+EpXiu16dSr9o+EOU8P16F0KfB+Ws3kZ+NVAosD4LX8K85EAihwqm0do
         j9sjCuEJ3+qv1QlbmfulrIiiCOXRXK69S9YoxtyImn9/+2PUFQ20aXcMNlOxlMReLAaO
         TLiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=r4FAAc165g+WsCZKbB8bO8geNANYXmPPZMDe3iqdbFs=;
        b=SRhFuCxtQUm9txqa80UCiTXB/DQf2CzFOeqWWyn5RuDRu8NHgiM8S6xxVkCLjzQDbt
         vn/zldFVwb8Zaaue2piHJG5uiEhqRiALosSj9LQH+muOMh/l4wEUndY+u75hzzFe5eDD
         mrXiAQGuhvDlt8jzZwHQ/jK7XeO3QoHIeJQK2yj31IYUJrlDyKpSRmAiSzshCZAVT69M
         Eh6k1MLQKVpM8t+B6OpJTRuUrEb7C+Ll7UYjVhB4TG4pyTRlGHA3a8ZVmxk1mnO6jYwn
         urefJ7ZKSQ1t6RzxAc2tQPTRKJVs2fiwI/vQ1AUz3sVREvHxWz8aH1J56zZk1QBGLIRM
         ELmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id f70si25139960oib.264.2019.04.16.05.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 05:57:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id A5C95F7F2C2FD5AC0BC7;
	Tue, 16 Apr 2019 20:57:10 +0800 (CST)
Received: from [127.0.0.1] (10.177.219.49) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Tue, 16 Apr 2019
 20:57:09 +0800
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
References: <20190412040240.29861-1-yuyufen@huawei.com>
 <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
 <20190415061618.GA16061@hori.linux.bs1.fc.nec.co.jp>
 <20190415091500.GG3366@dhcp22.suse.cz>
 <f063c3e7-1b37-7592-14c2-78b494dbd825@oracle.com>
From: yuyufen <yuyufen@huawei.com>
Message-ID: <a08b3f2a-e7a6-6f1a-7800-1939ad3316c3@huawei.com>
Date: Tue, 16 Apr 2019 20:57:08 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <f063c3e7-1b37-7592-14c2-78b494dbd825@oracle.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Originating-IP: [10.177.219.49]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/4/16 1:11, Mike Kravetz wrote:
> On 4/15/19 2:15 AM, Michal Hocko wrote:
>> On Mon 15-04-19 06:16:15, Naoya Horiguchi wrote:
>>> On Fri, Apr 12, 2019 at 04:40:01PM -0700, Mike Kravetz wrote:
>>>> On 4/11/19 9:02 PM, Yufen Yu wrote:
>>>>> Commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
>>>> ...
>>>>> However, for inode mode that is 'S_ISBLK', hugetlbfs_evict_inode() may
>>>>> free or modify i_mapping->private_data that is owned by bdev inode,
>>>>> which is not expected!
>>>> ...
>>>>> We fix the problem by moving resv_map to hugetlbfs_inode_info. It may
>>>>> be more reasonable.
>>>> Your patches force me to consider these potential issues.  Thank you!
>>>>
>>>> The root of all these problems (including the original leak) is that the
>>>> open of a block special inode will result in bd_acquire() overwriting the
>>>> value of inode->i_mapping.  Since hugetlbfs inodes normally contain a
>>>> resv_map at inode->i_mapping->private_data, a memory leak occurs if we do
>>>> not free the initially allocated resv_map.  In addition, when the
>>>> inode is evicted/destroyed inode->i_mapping may point to an address space
>>>> not associated with the hugetlbfs inode.  If code assumes inode->i_mapping
>>>> points to hugetlbfs inode address space at evict time, there may be bad
>>>> data references or worse.
>>> Let me ask a kind of elementary question: is there any good reason/purpose
>>> to create and use block special files on hugetlbfs?  I never heard about
>>> such usecases.
> I am not aware of this as a common use case.  Yufen Yu may be able to provide
> more details about how the issue was discovered.  My guess is that it was
> discovered via code inspection.

In fact, we discover the issue by running syzkaller. The program like:

15:39:59 executing program 0:
r0 = openat(0xffffffffffffff9c, &(0x7f0000000040)='./file0/file0\x00', 
0x44000, 0x1)
r1 = syz_open_dev$vcsn(&(0x7f00000000c0)='/dev/vcs#\x00', 0x3f, 0x202000)
renameat2(r0, &(0x7f0000000140)='./file0\x00', r0, 
&(0x7f0000000180)='./file0/file0/file0\x00', 0x4)
mkdir(&(0x7f0000000300)='./file0\x00', 0x0)
mount(0x0, &(0x7f0000000200)='./file0\x00', 
&(0x7f0000000240)='hugetlbfs\x00', 0x0, 0x0)
mknod$loop(&(0x7f0000000000)='./file0/file0\x00', 0x6000, 
0xffffffffffffffff)

Yufen
Thanks

>
>>>                  I guess that the conflict of the usage of ->i_mapping is
>>> discovered recently and that's because block special files on hugetlbfs are
>>> just not considered until recently or well defined.  So I think that we might
>>> be better to begin with defining it first.
> Unless I am mistaken, this is just like creating a device special file
> in any other filesystem.  Correct?  hugetlbfs is just some place for the
> inode/file to reside.  What happens when you open/ioctl/close/etc the file
> is really dependent on the vfs layer and underlying driver.
>
>> A absolutely agree. Hugetlbfs is overly complicated even without that.
>> So if this is merely "we have tried it and it has blown up" kinda thing
>> then just refuse the create blockdev files or document it as undefined.
>> You need a root to do so anyway.
> Can we just refuse to create device special files in hugetlbfs?  Do we need
> to worry about breaking any potential users?  I honestly do not know if anyone
> does this today.  However, if they did I believe things would "just work".
> The only known issue is leaking a resv_map structure when the inode is
> destroyed.  I doubt anyone would notice that leak today.
>
> Let me do a little more research.  I think this can all be cleaned up by
> making hugetlbfs always operate on the address space embedded in the inode.
> If nothing else, a change or explanation should be added as to why most code
> operates on inode->mapping and one place operates on &inode->i_data.


