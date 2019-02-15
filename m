Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 196D7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 07:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD5E7222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 07:08:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD5E7222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 546208E0002; Fri, 15 Feb 2019 02:08:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F48E8E0001; Fri, 15 Feb 2019 02:08:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40A758E0002; Fri, 15 Feb 2019 02:08:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F15FA8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 02:08:47 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id f10so1193687plr.18
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 23:08:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=oA3/gZW5v4knB6Ag0NZQLK7Fhj9IpK+k1LOX7/P/XDw=;
        b=TMbRP4A0xCDBJuPLPuuNBC8emvq6s/hNf6QiRp8gwRlTq+kgmr04ki4q/Eg5sdK5DM
         n0hB/+dz640O0KUyrCuRkY5R25Hv3BidZyxCcz9JxG5FohvLrrpnGRcFmeCfkp/KKnqZ
         kptLAc6v3+xTCAU6588wBucWIM7qwXze0r6vfIVObTq4EVf/tlMn530L7n/2XIH9AJlS
         AUmswpXPQa1LWhb+3SiBdepLOfBpUAImdA9e47UZdkHNVQTz8aVroaR2WdRtNqw4kLfj
         Cs1oAE9opQXcONudZibwItG/GUsy1UkbQefGJBmDKGbY2fuEZUKi3GMNwBjXgHP/8+UQ
         /raQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubzuQTFbs/iNyt18QOnIn0YEGFPedXIgrcIurHL/Xq6dx7IxE8g
	Fv+uEhJvTydE+8lpc6gUIbxArOJkr1lBy6gL91WMut+9MXrTk3BvnFlmhUZdcXF3P+xKUhqjiKI
	japDqjfIzC97wSGGDxA6EFRaoKbPz1W6D6GmpF7A7dRBYkDoS74OqI3xlGDiiS+2F/A==
X-Received: by 2002:a17:902:45:: with SMTP id 63mr807084pla.281.1550214524256;
        Thu, 14 Feb 2019 23:08:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYNo3UD/Nlr2WuKtYYz/oUCgq2NffOTvvMttuJdXi/8LM4vf0gk5CabAvnnH1YKwCkUORlu
X-Received: by 2002:a17:902:45:: with SMTP id 63mr807019pla.281.1550214523314;
        Thu, 14 Feb 2019 23:08:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550214523; cv=none;
        d=google.com; s=arc-20160816;
        b=f1r7rKwgsQOqC6HzxO0jx9NaH1vcBeMV0CDWFrzJSec5k25Ripe2d+1vfmK0mVKegD
         RLMRdEP/qqcb0Qs0m/Fb3t+nyfs0h+mGsyDcr1AJZSYYhMd2YAmFMrHh6106TUoCbPtt
         IUmrz5StxibluvaG6eDtOMiu89FadBT3C2kS1BgnULK1ciiE7siHxKOWKmgR8gJuuoWr
         Hih/OWGLPxzMo7B4nEZ8PbVNe2Yr8Muo8fA0zGG2APVNbyExFPPfUiypmllSlfEcx0TW
         UhVNcZNZ3h1alJ+nmop3xv7tRDAdgWy8M+JBAKLYD3co9euYckixgLCNRibHD7TMT2CF
         7mbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=oA3/gZW5v4knB6Ag0NZQLK7Fhj9IpK+k1LOX7/P/XDw=;
        b=XWiEWjkiiaU9gTYTMqPc8iCzWrk3YXbezg5zOJT9/vg2NTL/aPP83uRgUdCEe2QgnR
         5fgAnxLHJNPv6gnZSLH/HJ7L67KnN9wAFkbf48yIbxrIyj6T2Z4fa2ZbMXYamUekq5kN
         p1r+1Znt86TkKwghzdhybLQL58+IHnKZZ2zwM/f93xIFcDQ/5AcPqMy62l95TyAsK1Pj
         D38W9Hb77CFNgeG0VvRXHD4XUrCm5vf9FuY8sxgLoWTuT9ik6H08gGj7vLwy/atqoBBK
         4duyfIO2Wmc9wem3DzM0gqlNXxRRaxtcgpns6S+qXS+nryiwzM3vPdN4EK1EIEn1L2o0
         LrMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w14si4011985pga.212.2019.02.14.23.08.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 23:08:43 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 23:08:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,371,1544515200"; 
   d="scan'208";a="138822067"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by orsmga001.jf.intel.com with ESMTP; 14 Feb 2019 23:08:39 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  Tim Chen <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,  Jérôme Glisse <jglisse@redhat.com>,  Andrea Arcangeli <aarcange@redhat.com>,  David Rientjes <rientjes@google.com>,  Rik van Riel <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang <dave.jiang@intel.com>,  Daniel Jordan <daniel.m.jordan@oracle.com>,  Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190214143318.GJ4525@dhcp22.suse.cz>
Date: Fri, 15 Feb 2019 15:08:36 +0800
In-Reply-To: <20190214143318.GJ4525@dhcp22.suse.cz> (Michal Hocko's message of
	"Thu, 14 Feb 2019 15:33:18 +0100")
Message-ID: <871s49bkaz.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko <mhocko@kernel.org> writes:

> On Mon 11-02-19 16:38:46, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> When swapin is performed, after getting the swap entry information from
>> the page table, system will swap in the swap entry, without any lock held
>> to prevent the swap device from being swapoff.  This may cause the race
>> like below,
>> 
>> CPU 1				CPU 2
>> -----				-----
>> 				do_swap_page
>> 				  swapin_readahead
>> 				    __read_swap_cache_async
>> swapoff				      swapcache_prepare
>>   p->swap_map = NULL		        __swap_duplicate
>> 					  p->swap_map[?] /* !!! NULL pointer access */
>> 
>> Because swapoff is usually done when system shutdown only, the race may
>> not hit many people in practice.  But it is still a race need to be fixed.
>> 
>> To fix the race, get_swap_device() is added to check whether the specified
>> swap entry is valid in its swap device.  If so, it will keep the swap
>> entry valid via preventing the swap device from being swapoff, until
>> put_swap_device() is called.
>> 
>> Because swapoff() is very rare code path, to make the normal path runs as
>> fast as possible, disabling preemption + stop_machine() instead of
>> reference count is used to implement get/put_swap_device().  From
>> get_swap_device() to put_swap_device(), the preemption is disabled, so
>> stop_machine() in swapoff() will wait until put_swap_device() is called.
>> 
>> In addition to swap_map, cluster_info, etc.  data structure in the struct
>> swap_info_struct, the swap cache radix tree will be freed after swapoff,
>> so this patch fixes the race between swap cache looking up and swapoff
>> too.
>> 
>> Races between some other swap cache usages protected via disabling
>> preemption and swapoff are fixed too via calling stop_machine() between
>> clearing PageSwapCache() and freeing swap cache data structure.
>> 
>> Alternative implementation could be replacing disable preemption with
>> rcu_read_lock_sched and stop_machine() with synchronize_sched().
>
> using stop_machine is generally discouraged. It is a gross
> synchronization.
>
> Besides that, since when do we have this problem?

For problem, you mean the race between swapoff and the page fault
handler?  The problem is introduced in v4.11 when we avoid to replace
swap_info_struct->lock with swap_cluster_info->lock in
__swap_duplicate() if possible to improve the scalability of swap
operations.  But because swapoff is a really rare operation, I don't
think it's necessary to backport the fix.

Best Regards,
Huang, Ying

