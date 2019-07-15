Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 408CEC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 12:10:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2F922080A
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 12:10:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2F922080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A0F46B0006; Mon, 15 Jul 2019 08:10:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 451F96B0007; Mon, 15 Jul 2019 08:10:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 341A66B0008; Mon, 15 Jul 2019 08:10:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9E726B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 08:10:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so13468949edr.7
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 05:10:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=UuuNbPRY0c3mzJC92j4EJVmareBiHQSi5whjuhFbQA4=;
        b=pwr9lcvlzlEHVSePvbtZffsbWWaqmUAe9cQYEaYVB0s5+jKgRvHCRTM4lP+BAhnWFk
         4B3/Jf79rd2DR2r2Br1hV22NT72ItjemwlAdMcLoSIWpYTSrKill86/ZH/aaHABmCwsB
         uJHKKHNMe9JBvVSbiBO4AMpHFtA/cQnLadSXOWIlbYCIwnFochZDQMFo6LuJw2Lfhy4Y
         p4h+ubRA7eLN/aWt8JhFPA5SJgju9ZEJazXNlPWyILOGvjt9mGXhsjP0XqrpBM41uJU9
         gC6/zrVtABwUTtV0ojSyn8uG+A/TacPKpL4Y5U88sxMRscElqWv/xprsBm1ClKOrqaY7
         YipA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAV9S3uGpKMjb1cTfAyyeReM2qPL0WOBjId4Y8ND220oPmBuFYPc
	znjg9ZLijQGQ7JQsVhqYplAVxG/mN3kBob5J6LmE75aMmlUD/EcjGeXWZuQAB43H0LFtcH6dRLw
	DTVq/SstC77lijEHAPzQYiJOs3+028cHLcBNap9wQfgY9FifGiOVmruzg8ePFKM2YUA==
X-Received: by 2002:a17:906:c802:: with SMTP id cx2mr11220264ejb.114.1563192632464;
        Mon, 15 Jul 2019 05:10:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzX/hewpo3+sW307EYDvSuuKwqf0a4grcMsDznL48TsvI95BLAkOIFii2T4MJ2grQyVxrqp
X-Received: by 2002:a17:906:c802:: with SMTP id cx2mr11220189ejb.114.1563192631497;
        Mon, 15 Jul 2019 05:10:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563192631; cv=none;
        d=google.com; s=arc-20160816;
        b=T89PXbu2F3lYJb1wejycMfOmQTuADTw/dQ63xoiZloXUc+o+PsYeqJ/M0ESwjDwmgV
         oHdXYK7PGqs86j/nxTG6fetHcQggPhgFrus+1LX66t1Ixu24WSOvYE+CFXkE71tkUKkN
         Xv5CeRAYLG+NUNOECDRRPCw19Twaz1vKt4X3BxqWqLkNJIh/zcXVtjR3USUlM9iTvcnq
         MVlHE20bkFxvIvDlPqHjsr4pLuWtbsCrqTumnra7YLtl/5H5aJqQY097f1At8LxmTgR3
         w9Tcp/ynA0OWK5sDtks61lEVsgkjX36jjdmjh+Fd/1Dd8S5CGKzsHfAfnkXzqYvEEjBK
         sW8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=UuuNbPRY0c3mzJC92j4EJVmareBiHQSi5whjuhFbQA4=;
        b=KppGKS4N+ArEVS+4J4vJjYn0HQPOJLubEmReh+I4MVvn1Nw3IKMacpip5GWTFus8Xw
         GBRlvjPzerYG/SNW949QsAuWaRTiQgOX3//7+XAPl+1lFekcf2XWY9/EMypD5oJi/KSJ
         bVU4x4pBuBYP5odXSAoi8/DvXNgSaydgFdHCG3ACvZffulnZ6McwORwLS8QcbRPQrNe3
         0JDAsPPhreZKqWNerxzlj88lV5iAESUNwrFeQM7qh7FuFH59jZFdVa6uA7XQ8HJV2QoC
         gYTQLRbxGJ8Bf6oI48+GeeHWwG58BbiFcnH0+muMoZzx7wcfsYZLj4VE04HxWJc1U+hI
         3www==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si10355895edd.173.2019.07.15.05.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 05:10:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1D765AF0B;
	Mon, 15 Jul 2019 12:10:30 +0000 (UTC)
Date: Mon, 15 Jul 2019 14:10:25 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: Peter Zijlstra <peterz@infradead.org>, keescook@chromium.org,
	hannes@cmpxchg.org, vdavydov.dev@gmail.com, mcgrof@kernel.org,
	mhocko@kernel.org, linux-mm@kvack.org,
	Ingo Molnar <mingo@redhat.com>, riel@surriel.com,
	Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
Message-ID: <20190715121025.GN9035@blackbody.suse.cz>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134754.GD3402@hirez.programming.kicks-ass.net>
 <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
 <20190712075815.GN3402@hirez.programming.kicks-ass.net>
 <37474414-1a54-8e3a-60df-eb7e5e1cc1ed@linux.alibaba.com>
 <20190712094214.GR3402@hirez.programming.kicks-ass.net>
 <f8020f92-045e-d515-360b-faf9a149ab80@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f8020f92-045e-d515-360b-faf9a149ab80@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Yun.

On Fri, Jul 12, 2019 at 06:10:24PM +0800, 王贇  <yun.wang@linux.alibaba.com> wrote:
> Forgive me but I have no idea on how to combined this
> with memory cgroup's locality hierarchical update...
> parent memory cgroup do not have influence on mems_allowed
> to it's children, correct?
I'd recommend to look at the v2 of the cpuset controller that implements
the hierarchical behavior among configured memory node sets.

(My comment would better fit to 
    [PATCH 3/4] numa: introduce numa group per task group
IIUC, you could use cpuset controller to constraint memory nodes.)

For the second part (accessing numa statistics, i.e. this patch), I
wonder wheter this information wouldn't be better presented under the
cpuset controller too.

HTH,
Michal

