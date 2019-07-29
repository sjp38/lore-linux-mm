Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39E83C76192
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04EEF2070B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:20:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04EEF2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 993258E0005; Mon, 29 Jul 2019 04:20:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 943EE8E0002; Mon, 29 Jul 2019 04:20:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80B438E0005; Mon, 29 Jul 2019 04:20:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47F328E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:20:08 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x18so37982219pfj.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:20:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=loBkav+SVwnYBMcv6F0k5dMqgWh8nEXO64nEXvoYfqw=;
        b=l4sEh1vG5DrEc8LFFN2vEPIvEnhmuB34XHjmxbIee2UiEh2cJRl+j7VtMtcKi/waAH
         JDqcmyG7muj+gMealxPcTShEI1ceGwwF/oyd+hX6VxLpYmKGMOgWISGYCWMPHHH/VZ9O
         zaktFv9dBmR3oLzJAFfN+bxhtJt5XkS/bf7FpmPEJDnh6PpdhpAydv/KWitKGLhQoeQS
         aQO191VKjRg87fdUeGi5PSuIA+6Ca5RUoYoqBiGJTcO8McpXYmjsW+uCtydrFXB4xubC
         48wta6yn7VuDMdE4Izvh9p3AFOIr+XFE1ZAwYD2dzRcv/oIuuOi3yWuJn5OIA4lS/elM
         xgUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXHhauzgSePhp5b4WX7NQ7Em0kS4uDVIiqCKBDK2Wd+WdYfVT4k
	pAAUxhdj9WQeLvg5+Zh89zY07PrqFCavO6AD0R/aEWNwemF64dCrxFpCWw32DpXzXujoqq4M207
	98Qn6Y9P9Yb0zHZw+5u2YE/jM+FVjbVHdcR2jsD6AxUZVs1rwjROtuIpkim5F+uBoXA==
X-Received: by 2002:aa7:9092:: with SMTP id i18mr35000888pfa.101.1564388407925;
        Mon, 29 Jul 2019 01:20:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9OcrSzuVJM0BKhMMxSVrk7ayrev2HwiEYBPw5wyiEG8IbDaCwYVPyjobC9OuEVQgjkPx3
X-Received: by 2002:aa7:9092:: with SMTP id i18mr35000832pfa.101.1564388407188;
        Mon, 29 Jul 2019 01:20:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564388407; cv=none;
        d=google.com; s=arc-20160816;
        b=TbGzOfJhJ9pVAPCBhg6kFdBHl3497Uzb0fxtJ97dxWdIOnitc5zRPbzgTe/KAXY8oR
         0V3/28L/sNheBgXkWhI4IH9+gJ2cVv97OSvZAO2UyhegpUmwTWiCS++Htuo1JiWNA/Sy
         xxh0YbyV8E+uRPlZQhaKcUElaah5xrifJPKkdEPzZSOjHUvKNg5kqu1GBsLR1RaaiX4V
         BC3zR4S5NKLuGoyV2u9Cn26YLio2t54be8FPTj29ALRfAxkSTl3cstEvjMUn/IWYl4Om
         fkC8eDXa9mCtvabYRBUiJsBUOYMgfv3oJYchgJbi+JxxlnZLw0n6+TYDlJjWipW9Q1re
         RE3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=loBkav+SVwnYBMcv6F0k5dMqgWh8nEXO64nEXvoYfqw=;
        b=NF3eE3inwk7GeNaPIVNWBZeJjaqfSpAzkSb/GrNGFoa2xdZ3Jcj8ircZ8Fo4Gl7gTi
         5Q8pIXWjCGvNo1TbxPk/DEQAnxXKbmx6uUobOw3zCL0kKpmJI9JIo+D5NZoJnLv+hByn
         5hBEcT2L+YfUlPwFV5LFAnUIHCKZFFpZ6snEPhhz8pBechYk78jjvS3+6aqe30hslyn5
         KH6xfw0ZlEyMxfNJLGtd+NlltOM0256cLc3Gx6LgiDjKyaWcPpXW79KnSfLo3P4xxeDG
         2FOCZIR3nVPafOfB1hdXMoZ22+CU8qYQgdpdx9eaiHvtyiZHq16k+sLCCEVpiLaRj3UE
         QktA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id z17si25708820pgj.147.2019.07.29.01.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 01:20:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jul 2019 01:16:30 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,322,1559545200"; 
   d="scan'208";a="165395411"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga008.jf.intel.com with ESMTP; 29 Jul 2019 01:16:28 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>,  Ingo Molnar <mingo@kernel.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Rik van Riel <riel@redhat.com>,  Mel Gorman <mgorman@suse.de>,  <jhladky@redhat.com>,  <lvenanci@redhat.com>,  Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] autonuma: Fix scan period updating
References: <20190725080124.494-1-ying.huang@intel.com>
	<20190725173516.GA16399@linux.vnet.ibm.com>
	<87y30l5jdo.fsf@yhuang-dev.intel.com>
	<20190726092021.GA5273@linux.vnet.ibm.com>
	<87ef295yn9.fsf@yhuang-dev.intel.com>
	<20190729072845.GC7168@linux.vnet.ibm.com>
Date: Mon, 29 Jul 2019 16:16:28 +0800
In-Reply-To: <20190729072845.GC7168@linux.vnet.ibm.com> (Srikar Dronamraju's
	message of "Mon, 29 Jul 2019 12:58:45 +0530")
Message-ID: <87wog145nn.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:

>> >> 
>> >> if (lr_ratio >= NUMA_PERIOD_THRESHOLD)
>> >>     slow down scanning
>> >> else if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
>> >>     if (NUMA_PERIOD_SLOTS - lr_ratio >= NUMA_PERIOD_THRESHOLD)
>> >>         speed up scanning
>> 
>> Thought about this again.  For example, a multi-threads workload runs on
>> a 4-sockets machine, and most memory accesses are shared.  The optimal
>> situation will be pseudo-interleaving, that is, spreading memory
>> accesses evenly among 4 NUMA nodes.  Where "share" >> "private", and
>> "remote" > "local".  And we should slow down scanning to reduce the
>> overhead.
>> 
>> What do you think about this?
>
> If all 4 nodes have equal access, then all 4 nodes will be active nodes.
>
> From task_numa_fault()
>
> 	if (!priv && !local && ng && ng->active_nodes > 1 &&
> 				numa_is_active_node(cpu_node, ng) &&
> 				numa_is_active_node(mem_node, ng))
> 		local = 1;
>
> Hence all accesses will be accounted as local. Hence scanning would slow
> down.

Yes.  You are right!  Thanks a lot!

There may be another case.  For example, a workload with 9 threads runs
on a 2-sockets machine, and most memory accesses are shared.  7 threads
runs on the node 0 and 2 threads runs on the node 1 based on CPU load
balancing.  Then the 2 threads on the node 1 will have "share" >>
"private" and "remote" >> "local".  But it doesn't help to speed up
scanning.

Best Regards,
Huang, Ying

