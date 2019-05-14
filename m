Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4664CC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 20:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0355920850
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 20:44:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0355920850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 746906B0005; Tue, 14 May 2019 16:44:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CFCF6B0006; Tue, 14 May 2019 16:44:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 549926B0007; Tue, 14 May 2019 16:44:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18BD56B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 16:44:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n4so273197pgm.19
        for <linux-mm@kvack.org>; Tue, 14 May 2019 13:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=akUzaMMRw679+Ad13VeTVFpCPNQY/rT9Sy2VAxz00Tg=;
        b=B9YmaXDBl8kSS0kGKnlk2T5l4zZnyu1Wl47sqO7fKXQh0pPkVTv7GiNnUHDWcN/IYA
         6LLtM4q/A9SRpPUKHw8MPevJ/mWvH/pUBaTLEA+4KVg/a2QN+hHV9zEqX0FptonIYy0L
         gaOYKWblU3z/2FLya48wvMEpeByjLuoktiW9FIYMN0/1w5pwZtJn/jgg89UEfy5/Ublh
         jqlW+Fc/Mh+N1di7Oy0pL78IsvqtBqeo+IhNLWgE8hoE1ZLrE4ot5RNNtd5j5V704BUN
         ZjrAj5Prbn1UHvua4aH8Q6zKbnFngTJPaWxDpalM62TeJGKgmGfHcWqpcNcrDLUzTita
         JFBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWnum+hNAB23/w09EazaASgGeofe2/1ZLSBjklEwgKqmjO6okby
	HgsaioroXYXExK2E/qIsM2i1qVN9dpsbeMGDBHsAUaD112Y8D5tOgN/UYZADi4ydmpludgIRkgz
	hAyBqE5xxwoQdGP8ycR7/EgnXNuOPCIvbioCShHeJvXunJVBpX8OmSws5KIvt53cQxg==
X-Received: by 2002:a62:2805:: with SMTP id o5mr42874517pfo.256.1557866683573;
        Tue, 14 May 2019 13:44:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3wGajhWbtb9/9f6G8aAyF/Sg6pkkJ2za3lpDYP40tS0O2qRAHRFBqHgYSyM9XNjg49ioD
X-Received: by 2002:a62:2805:: with SMTP id o5mr42874450pfo.256.1557866682829;
        Tue, 14 May 2019 13:44:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557866682; cv=none;
        d=google.com; s=arc-20160816;
        b=K0r1ThBPlSfmSQh5GnyIxU+drnXG1KPY/hjYb/PRwBlnl8+ZKJ8p5b0/AgfnLVDNVo
         Xy+SM8IKGeJ+VruKRhqHCEjHWQGjjW7UNuTpcLCqs93DrBcfIIJiuEmORRcxDXXKBnZU
         aQO5ZLS9IF41jFaXFNDT1v1Dmdz7gm3EIRb2hoB/tdc/fJsRkN/QGzy38gz61UaVZYUT
         nfp+wmWvuFkRNaEnwrRjas6Pj29dxOcwCk1Jb+DR8YpWzCLZAiHVz1gcn1iteW1GLJa2
         e6Ln2Ly9+AW13J4HSfkrolCNDvFEskeEhfGWcFO/LhH7nYKqiZeyTerPVGpTvdNiaDUY
         HwXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=akUzaMMRw679+Ad13VeTVFpCPNQY/rT9Sy2VAxz00Tg=;
        b=1H5renkl/Xu/WYzWXzv9HKXq57V6BqquGUG3V+bFuBZosvz1MZasuFAB5FUOKRoS6F
         p8WdiTvK91BbGMAc297Rb6U5MgAkFrTMufOEKtXYudoYl4Mh6rdsaY7vvz7q/QY7XTdd
         K2FvY/KkKMQtwk81qURZL43EOdanQKJAt6VPXirmQ0P7ss3EaYUsmyJ9H1KKEbolO4TC
         FWVa64Klos2Ayl05h8yYMyveQl8ek0UsR/xlCbVphzlxtETlzvzFY+fOj4g2PJRSD0pJ
         avMOK5L/8ayqrp93dwi8GamNpnyyo4CO163Eanxew7Pbty2Mo80ihY99IiuDuLlTYVRR
         G1uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id u28si8184493pga.131.2019.05.14.13.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 13:44:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TRkUBgw_1557866676;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRkUBgw_1557866676)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 15 May 2019 04:44:40 +0800
Subject: Re: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
To: Michal Hocko <mhocko@kernel.org>, Yang Shi <shy828301@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Mel Gorman <mgorman@techsingularity.net>, kirill.shutemov@linux.intel.com,
 Hugh Dickins <hughd@google.com>, Shakeel Butt <shakeelb@google.com>,
 william.kucharski@oracle.com, Andrew Morton <akpm@linux-foundation.org>,
 Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513080929.GC24036@dhcp22.suse.cz>
 <c3c26c7a-748c-6090-67f4-3014bedea2e6@linux.alibaba.com>
 <20190513214503.GB25356@dhcp22.suse.cz>
 <CAHbLzkpUE2wBp8UjH72ugXjWSfFY5YjV1Ps9t5EM2VSRTUKxRw@mail.gmail.com>
 <20190514062039.GB20868@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <509de066-17bb-e3cf-d492-1daf1cb11494@linux.alibaba.com>
Date: Tue, 14 May 2019 13:44:35 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190514062039.GB20868@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/13/19 11:20 PM, Michal Hocko wrote:
> On Mon 13-05-19 21:36:59, Yang Shi wrote:
>> On Mon, May 13, 2019 at 2:45 PM Michal Hocko <mhocko@kernel.org> wrote:
>>> On Mon 13-05-19 14:09:59, Yang Shi wrote:
>>> [...]
>>>> I think we can just account 512 base pages for nr_scanned for
>>>> isolate_lru_pages() to make the counters sane since PGSCAN_KSWAPD/DIRECT
>>>> just use it.
>>>>
>>>> And, sc->nr_scanned should be accounted as 512 base pages too otherwise we
>>>> may have nr_scanned < nr_to_reclaim all the time to result in false-negative
>>>> for priority raise and something else wrong (e.g. wrong vmpressure).
>>> Be careful. nr_scanned is used as a pressure indicator to slab shrinking
>>> AFAIR. Maybe this is ok but it really begs for much more explaining
>> I don't know why my company mailbox didn't receive this email, so I
>> replied with my personal email.
>>
>> It is not used to double slab pressure any more since commit
>> 9092c71bb724 ("mm: use sc->priority for slab shrink targets"). It uses
>> sc->priority to determine the pressure for slab shrinking now.
>>
>> So, I think we can just remove that "double slab pressure" code. It is
>> not used actually and looks confusing now. Actually, the "double slab
>> pressure" does something opposite. The extra inc to sc->nr_scanned
>> just prevents from raising sc->priority.
> I have to get in sync with the recent changes. I am aware there were
> some patches floating around but I didn't get to review them. I was
> trying to point out that nr_scanned used to have a side effect to be
> careful about. If it doesn't have anymore then this is getting much more
> easier of course. Please document everything in the changelog.

Thanks for reminding. Yes, I remembered nr_scanned would double slab 
pressure. But, when I inspected into the code yesterday, it turns out it 
is not true anymore. I will run some test to make sure it doesn't 
introduce regression.

BTW, I noticed the counter of memory reclaim is not correct with THP 
swap on vanilla kernel, please see the below:

pgsteal_kswapd 21435
pgsteal_direct 26573329
pgscan_kswapd 3514
pgscan_direct 14417775

pgsteal is always greater than pgscan, my patch could fix the problem.

Anyway, I will elaborate these in the commit log.


