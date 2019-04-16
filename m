Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9B75C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91517217D7
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:17:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91517217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E38C6B000A; Tue, 16 Apr 2019 19:17:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26ABE6B000C; Tue, 16 Apr 2019 19:17:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10DDB6B000D; Tue, 16 Apr 2019 19:17:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C50AF6B000A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:17:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i23so15051989pfa.0
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:17:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=skB516ZXV+l7B5+p8B5xNo5o9N7ZAalDjokO43lzUXc=;
        b=DqiMDcuxJcqDZYMV/zh4gXn3Fax0j0aayP1olrhX6Q55r4rVlT9va1mhu4mQb44aix
         ADdvwxrvByNq7FqS4feujGWJ9nc1x2/gjcZ64tXOYIBYldW4AWTdColCvC/EkU0j4ZSI
         bpkeYFQUacdkL8gWOW0TfpvCAN5pMvDRJeSVBO76ATyfML0ZfgxVrPRN+tCtPGMqzADv
         avvGnScpXfM0pJJbGLGHZ5UUooTP8o24ANTLVMHXP4k9BpFtYRenOOgcuiqPAhAzGRct
         BlcVjZiBregiTM3E/i3c4T1obQ/fa9JetjRngZIfdHeCAAfmgT57c9TNetDzIphgZ2gG
         zTuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUDubK8LNqkTN7fp+olGqYQ2gdk0vPn/nV0BuwSRdhsxAaxJKen
	Wfepj7elaIahj8GrM6wK7h4qae356zeDkS2jmVX8Xp3x3efVZKGHQLJh+z8AXB1pDj68ZYJpUHk
	D/x84EipaiUQVeEq3UYrctFX61AWHt7admv3Oj1sA78hOq21s8gxaikKgOqnFbMxbRw==
X-Received: by 2002:a63:844a:: with SMTP id k71mr73888366pgd.138.1555456671462;
        Tue, 16 Apr 2019 16:17:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLjjr58Q1zG1y39ZMOaYLmgoKipTEaShHEj6StE/jcLxSkApyTRg7bbtNKvfCFbd+KmKqI
X-Received: by 2002:a63:844a:: with SMTP id k71mr73888323pgd.138.1555456670674;
        Tue, 16 Apr 2019 16:17:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555456670; cv=none;
        d=google.com; s=arc-20160816;
        b=KbLxJVFLvNOEV1ar57BbUdoclOgF2OAnXJyOlzPwSfEz322nSvb++vy/V9QaCH43Rr
         UFDOJ8ayA4SCuVkZHnOolv56//Rj36BEaBh4csAOZzrBdyon/MiolZAvXn8l44UEHS0m
         stRv6TPqxEHMW6uqdgSzajxHkI3bau8RkDIj0LNc/rrrMvIf2teFE0Gqzq+DGtW1DDYg
         3CFopcGEh5HpV28CCylQDmJTr/WItwAMSPMz8sEIdoDhMnJ+/cQki3bzQuuIC/eR+ggx
         gyBq1EqXguOgGD2wU8Vr6kb1zxo3KQD5iuYp67S+sLpfbMPjs+vhuTIGZQ2y6Txiffss
         AP9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=skB516ZXV+l7B5+p8B5xNo5o9N7ZAalDjokO43lzUXc=;
        b=lw3IuqHxOti889xnE8xNIrFtNIsAJq9RWCDyIIbyd6mqMi/a8fnVWE9jzz3CQP4hNi
         PvK4sEY070jXSZicV/hIxkJ4GnNhDlNsvKJkow/ov8d5MrE+4S+4CL6nGtRxP78AZCMq
         tVwsQDreLgDuHJFPp3JwRft03Sptx8/t9U3Dbw8PffambI9cDk4ijHaqan89cbNiFpjb
         dEVelTyXb9BijBL4+XREOx3aWrJlKP51jLAyCwU53BoK4l6056glSZ8pV1K2M7dsoPDz
         d78X3wPp0uox83PgyuXzSmIUlnl11bVMgBfLijXm1LTqe3WRqEke1LiKcVi49A5lNaGJ
         wVZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id l66si31290116pfi.62.2019.04.16.16.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 16:17:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPVBBj6_1555456664;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPVBBj6_1555456664)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Apr 2019 07:17:48 +0800
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <99320338-d9d3-74ca-5b07-6c3ca718800f@linux.alibaba.com>
 <1556283f-de69-ce65-abf8-22f6f8d7d358@intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <8bc32012-b747-3827-1814-91942357d170@linux.alibaba.com>
Date: Tue, 16 Apr 2019 16:17:44 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1556283f-de69-ce65-abf8-22f6f8d7d358@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/16/19 4:04 PM, Dave Hansen wrote:
> On 4/16/19 2:59 PM, Yang Shi wrote:
>> On 4/16/19 2:22 PM, Dave Hansen wrote:
>>> Keith Busch had a set of patches to let you specify the demotion order
>>> via sysfs for fun.  The rules we came up with were:
>>> 1. Pages keep no history of where they have been
>>> 2. Each node can only demote to one other node
>> Does this mean any remote node? Or just DRAM to PMEM, but remote PMEM
>> might be ok?
> In Keith's code, I don't think we differentiated.  We let any node
> demote to any other node you want, as long as it follows the cycle rule.

I recall Keith's code let the userspace define the target node. Anyway, 
we may need add one rule: not migrate-on-reclaim from PMEM node. 
Demoting from PMEM to DRAM sounds pointless.


