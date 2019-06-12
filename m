Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50730C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:49:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F26520684
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:49:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F26520684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C84F36B0003; Wed, 12 Jun 2019 08:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0D496B0006; Wed, 12 Jun 2019 08:49:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AADED6B0007; Wed, 12 Jun 2019 08:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA536B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:49:18 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id d62so7676626otb.4
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iSkw7N6qmkn7IS1okd5VLDUc1ofbhIKgr2ge0HvEoPM=;
        b=RFZbAiNvA1KxTipFnWMkpy5M4Kk0w2+ZgQ4VdhvVNvfrB0B1CjZQuWw9t3BSb5zSIS
         n6bzhu5uFGxdSWA/EHp4JChyKiBdgj8vTtoQg+o+HT/uxcbCOXZ7kL7xgVNUM8P7Bdco
         izeHIwiNQ7ko0jcMPhYBDqIT8UqG0HSZXquSEpPLlFGXO6uaDH6la2QZaQa4giDBotC6
         8ZkqAcHwr7anpFXKgdF0xOa7vL7i8UE7AS9bM76dw9b46DN9NuoReobipjtUA5540Lq0
         RA66TwxPN5uHYIT26Ei5/vXBEFcu1+pDrLkGy2CFOZ807NR34FQPNNDclYhEPaGrtAxY
         yhdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
X-Gm-Message-State: APjAAAUOREP8mA4lrKZlY2WI+xahoatQoUyqw21Nrn/c52FNUjgEBckI
	CI/UE9cYIOz7adRnLS/iw1WPO7IFHB723BD5EXu2KP9dVRYYGv0Q0DWAuzVQzxB7bZBPHKq+OvZ
	xxkITz2Gg/2f482KCtyXU5KIZQ57Ci4WXPgod8NASfLFOPwuMT+yIbb8ZQHkJZ4uGyQ==
X-Received: by 2002:aca:574e:: with SMTP id l75mr19286531oib.2.1560343758196;
        Wed, 12 Jun 2019 05:49:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwb7Rtcj2JFOFlIfbj+ozd9hKmt6GeOzwH9hpHO9SPBrrSCDnF+WOXlUIo/3Rb3NJzPv5AK
X-Received: by 2002:aca:574e:: with SMTP id l75mr19286507oib.2.1560343757504;
        Wed, 12 Jun 2019 05:49:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560343757; cv=none;
        d=google.com; s=arc-20160816;
        b=PcIsmCWgM8p3YF8Yqv7otTV3zdzzwxZ/j5gA3QQzBitPfQIyI2ee+jkCIAERwyWRLE
         hfGedx19x0Wgkhgn5F2x5MGcX5MpXOl6nOYHySaVLvgFB2pGCy2lwC+aKGAPU1AlVArH
         9u3+eAQfD8HM5FpiXkZaCrbdErO8HQwiV4HY/kZIljDrNd53GKMatiE9EZdD73wua13P
         qnv0QbuX8StRKBF6q/4DPKCblFgCVM/WbgBsWRkPkk/Sj/sZXzHbuUCYGg7xEh+3Aeyh
         o1ZHkOMqgD7BOGjU+EoY4e0roBuSdOYATCersvn70Gjki6QgQtwpgbfCq/df4VHHm/1K
         uHEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iSkw7N6qmkn7IS1okd5VLDUc1ofbhIKgr2ge0HvEoPM=;
        b=e8tqkTXw+CF3zQhfZVwAD62lbhDHOKkTk6WJCtW3XXMokfzUOffznRb20V9IXebwQd
         mkMVnVnEOzr5fQ/p5HETWNAFCYCnwDMOJE8ryPDz5+u1AkBr3QSktkQUxegQXtMGm+o/
         2Sy1GcGMJXnU5zFAX9Bkb/fDBzUHA/Fqg+gGDyLNhXFNYzm3FMyrcwc7fA+B5GXmlfVV
         7AUzKo5VzuVYL5nqor/CUDGyZaf61jONz4ZO80liqYWkZ6UdV9WlvryCMv6VPK+Pzym/
         dZ84UlXT2KXSCgnM18vrOBPzJrnJ5GnAz/1wYiPsFhGj4T2PGw0ElK1+Pq/QrzIsAQZA
         T9zA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id p78si5022920oic.108.2019.06.12.05.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 05:49:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id D58236C600BA13826720;
	Wed, 12 Jun 2019 20:49:11 +0800 (CST)
Received: from [127.0.0.1] (10.177.223.23) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.439.0; Wed, 12 Jun 2019
 20:49:07 +0800
Subject: Re: [PATCH v11 0/3] remain and optimize memblock_next_valid_pfn on
 arm and arm64
To: Jia He <hejianet@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
CC: Will Deacon <will.deacon@arm.com>, Ard Biesheuvel
	<ard.biesheuvel@arm.com>, Mark Rutland <mark.rutland@arm.com>, Michal Hocko
	<mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Kemi Wang
	<kemi.wang@intel.com>, Wei Yang <richard.weiyang@gmail.com>, Linux-MM
	<linux-mm@kvack.org>, Eugeniu Rosca <erosca@de.adit-jv.com>, Petr Tesarik
	<ptesarik@suse.com>, Nikolay Borisov <nborisov@suse.com>, Russell King
	<linux@armlinux.org.uk>, Daniel Jordan <daniel.m.jordan@oracle.com>, "AKASHI
 Takahiro" <takahiro.akashi@linaro.org>, Mel Gorman <mgorman@suse.de>,
	"Andrey Ryabinin" <aryabinin@virtuozzo.com>, Laura Abbott
	<labbott@redhat.com>, "Daniel Vacek" <neelx@redhat.com>, Vladimir Murzin
	<vladimir.murzin@arm.com>, "Kees Cook" <keescook@chromium.org>, Vlastimil
 Babka <vbabka@suse.cz>, "Johannes Weiner" <hannes@cmpxchg.org>, YASUAKI
 ISHIMATSU <yasu.isimatu@gmail.com>, "Jia He" <jia.he@hxt-semitech.com>, Gioh
 Kim <gi-oh.kim@profitbricks.com>, linux-arm-kernel
	<linux-arm-kernel@lists.infradead.org>, Steve Capper <steve.capper@arm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, James Morse
	<james.morse@arm.com>, "Philip Derrin" <philip@cog.systems>, Andrew Morton
	<akpm@linux-foundation.org>
References: <1534907237-2982-1-git-send-email-jia.he@hxt-semitech.com>
 <CAKv+Gu9u8RcrzSHdgXiqHS9HK1aSrjbPxVUSCP0DT4erAhx0pw@mail.gmail.com>
 <20180907144447.GD12788@arm.com>
 <84b8e874-2a52-274c-4806-968470e66a08@huawei.com>
 <CAKv+Gu9fd2Y7USDYnQdUuYd9L2OD99kU4A1x1JSF442KN96TTA@mail.gmail.com>
 <2de74de9-35b0-5e62-d822-1be59f0ef605@huawei.com>
 <8fdf5545-21b7-354c-4c4b-e1e92048864f@gmail.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <ed84966f-81ed-3be9-5b21-1fd92deea3cc@huawei.com>
Date: Wed, 12 Jun 2019 20:48:57 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.0
MIME-Version: 1.0
In-Reply-To: <8fdf5545-21b7-354c-4c4b-e1e92048864f@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.223.23]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/6/12 9:05, Jia He wrote:
>>
>>> So what I would like to see is the patch set being proposed again,
>>> with the new data points added for documentation. Also, the commit
>>> logs need to crystal clear about how the meaning of PFN validity
>>> differs between ARM and other architectures, and why the assumptions
>>> that the optimization is based on are guaranteed to hold.
>> I think Jia He no longer works for HXT, if don't mind, I can repost
>> this patch set with Jia He's authority unchanged.
> Ok, I don't mind that, thanks for your followup :)

That's great, I will prepare a new version with Ard's comments addressed
then repost.

Thanks
Hanjun

