Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DFCFC282DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:10:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6427C2075B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:10:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6427C2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9EF36B0003; Mon, 15 Apr 2019 18:10:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E28FC6B0006; Mon, 15 Apr 2019 18:10:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCAB56B0007; Mon, 15 Apr 2019 18:10:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92A806B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 18:10:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id l74so12663254pfb.23
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 15:10:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=xIxBz0bYPwo3nDe8jf9cWYhIJ/QmKwbpOk2+5pJiths=;
        b=Hu5j3H7PKWg/H8ag5j4984YbJGCJHBxCRCm24wCK3n9ixdsanI8S558yXZGYj3HwSI
         aeRfBaRu1DN/D67qEG5OTL8s129OC9Lrdm4blxVhPykNT1G+/AbLaV8r84RP0wT+bdKy
         MTZnvtBX8F3cmcA2d3WIlqIDIW7XWOZEVaJRZHuchjVTMp6l0IrARiC7bNbjkvHbpeR5
         0mj7uckDj6YDjtLhRjUSeUniITJBO3qCwsOzbgp+UqmI0vTTpCyrVCN0+21ago9n5yZC
         wk4cTYxxcAb4YdxVu/2d6LH1h46m5nxqfFGIoDVyI51fnqEnFFnduXgoBjPypAumLAjn
         rXtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUGhxBhS0FbDhj9+potJbbr+RTGYo6FYhwEHVopcEJ7kc3IsE97
	KsLoM/reOsSHeYV1bTWZouy22b0cHVp2vnOgpLrZM4BKJPgxPv3TWcuCyXmUZle1V76jUUbwwqX
	MsUHve09VbSIWYPfl4yMrc0YwuhF507pLyCNKBamtGFAfpQbhGU9pdr52+d58TJhFaw==
X-Received: by 2002:a63:4241:: with SMTP id p62mr72912549pga.379.1555366212150;
        Mon, 15 Apr 2019 15:10:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAYb6NCkyVMGO4MDfK1t31lWsk50CukLemfONqi+7k00YZWPrXof4I2kiDB3mAde5gEFfP
X-Received: by 2002:a63:4241:: with SMTP id p62mr72912487pga.379.1555366211484;
        Mon, 15 Apr 2019 15:10:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555366211; cv=none;
        d=google.com; s=arc-20160816;
        b=ARDo6lDzk62oiHVBtU7nLUHDI0SlvTO2CUCRoh+hz6gYU8ao+68gQfCwYJrWK+q3sl
         RPaRzf/Eqvt/wyS8y60iQQlj0xPCBAdxCq+CZ+O7v2h422rQ8sPOdJPHeyCWotN+LiLP
         uPSWFb58wXVrymaEkLJKXd/qwGQg4HPBtSmHRFaswR7Tw0EwYRbaK82Vn4Wex3yKvb17
         RB9A62EKSYuTlNWGD3lonnBUieKu26vdBUTsV8KVKdBV3G+cozUMz6JMRLpi3YO73BaM
         3Zbw56d3D8nyMbQ7o1wJQzMKBBjYjxWb0FmrBrGwqR7Fva79CWOPK4DbISSZCX0UnGVn
         l4Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xIxBz0bYPwo3nDe8jf9cWYhIJ/QmKwbpOk2+5pJiths=;
        b=XS2rZqwJdVsvSGCImRzJUMPESDAhFSdJj3pVAGVmJWatNYJy/ouZSOCn4qgrEClI4f
         N5uX0V3oTrIGMHGMj/NKOGXKPvqrTPHioztKYGnQT7gmdxAFPM6PGrfsVDGF74NSEUIy
         XEg/xQJNgWwdzNkrryPp+kaDhq1HnbY3KkAjpGlc/cARcL+u5NllXFjArdxlra1mxBcX
         4Z++DRU7TswGRDoU4ILDzbX6Ao1JDW2Wj3ou/O5CMrwThoOPuUMzlXI5eX9I0twsvAvQ
         O/+ObVkl78C1D4D4hjsRS4bNBSxiM9HwomUDodH4JrgyNPN9f8gOo0y5uG42dIbCJNC/
         s/vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id g1si21931713pgq.268.2019.04.15.15.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 15:10:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R721e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPP1TeS_1555366205;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPP1TeS_1555366205)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Apr 2019 06:10:08 +0800
Subject: Re: [v2 PATCH 5/9] mm: vmscan: demote anon DRAM pages to PMEM node
To: Dave Hansen <dave.hansen@intel.com>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <1554955019-29472-6-git-send-email-yang.shi@linux.alibaba.com>
 <bc4cd9b2-327d-199b-6de4-61561b45c661@intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <0f4d092d-1421-7163-d937-f8aa681db594@linux.alibaba.com>
Date: Mon, 15 Apr 2019 15:10:00 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <bc4cd9b2-327d-199b-6de4-61561b45c661@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/11/19 7:31 AM, Dave Hansen wrote:
> On 4/10/19 8:56 PM, Yang Shi wrote:
>>   include/linux/gfp.h            |  12 ++++
>>   include/linux/migrate.h        |   1 +
>>   include/trace/events/migrate.h |   3 +-
>>   mm/debug.c                     |   1 +
>>   mm/internal.h                  |  13 +++++
>>   mm/migrate.c                   |  15 ++++-
>>   mm/vmscan.c                    | 127 +++++++++++++++++++++++++++++++++++------
>>   7 files changed, 149 insertions(+), 23 deletions(-)
> Yikes, that's a lot of code.
>
> And it only handles anonymous pages?

Yes, for the time being. But, it is easy to extend to all kind of pages.

>
> Also, I don't see anything in the code tying this to strictly demote
> from DRAM to PMEM.  Is that the end effect, or is it really implemented
> that way and I missed it?

No, not restrict to PMEM. It just tries to demote from "preferred node" 
(or called compute node) to a memory-only node. In the hardware with 
PMEM, PMEM would be the memory-only node.

Thanks,
Yang


