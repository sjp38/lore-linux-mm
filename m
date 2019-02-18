Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7267AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 00:52:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B4CB2184E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 00:52:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B4CB2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8345E8E0002; Sun, 17 Feb 2019 19:52:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E3DE8E0001; Sun, 17 Feb 2019 19:52:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6847A8E0002; Sun, 17 Feb 2019 19:52:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 254E38E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 19:52:03 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q21so12452734pfi.17
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 16:52:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=LCTRL8N26w6VeA+ALDoKaNaBw3BD9ZLmf399vjPkAeY=;
        b=j2yTAXsrY3wpUIhLzXILQu38W7KAzr/QjNxG9lAfbMNQqCoFCLSO+MztizWGy5oM0+
         zf1xsko7wKvMm4NO1r3Vi0LWbrUidq1yMk1mWksPT39QyT0n9dV/HHhTMdNXPs79xFzb
         xA0S9TSFex01BSiZac7RWfilGQQtBJTKgIyPfiqsHq/tx+jIj/GLCbttdJHOO7HkXbn5
         YRC+NHs3eoYinsksCEpXHUAHg+NAXW6eveJijQoYMQKOCpEVkLs3L5atjMyiGTMakLa5
         M4igD/jZqeZy2WkCf2dzFTP0r7Bd7oH7uo+Rao3PLJbZr/KY81AGBqrHOAyU4hcXwx1g
         umLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ+2vy4BEvSIFuNHs4ltJOi7vyuhTkwsqt6mRM4EzEzlw2qwMB8
	CoEYhY7DEUvv4xxc7QcnrjvxLon9nyUV7/xV2n+1+DCnnQBG/8OAtQARmvkcUDWWFKVaqx0l0Bd
	bhCAh4X/6dVBoei0Tec5KBInTguz/3pS8TIhKTE78jZp9P/rW2jnenEkGJxY2J3ZdSw==
X-Received: by 2002:a62:cf81:: with SMTP id b123mr1480668pfg.29.1550451122806;
        Sun, 17 Feb 2019 16:52:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbWWhykrVf1RcqqTHcp2ihqn8xJ93haHPoc0+pc1X981avrgxCGwkdVemUZIlCr/2oTnEy1
X-Received: by 2002:a62:cf81:: with SMTP id b123mr1480574pfg.29.1550451121324;
        Sun, 17 Feb 2019 16:52:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550451121; cv=none;
        d=google.com; s=arc-20160816;
        b=EHTtHkRMnoW8TCrEkI7UjoGqS88NOTA730YbbseamQPAfoRpjeOj7rtBVpWk4omJJO
         MsRQFaPpCMH5pFxql8hO3Hh/juK9IPQZPyD6y/aHHP2b46E88Mv0mHuFQ6NM61ztvTYK
         B7g2/c1Qlys2doIguLsuTHrdE1+LtMrNwtaJkUjOKjADV2gOtOMaaR0hJ59ue7DaodOC
         gwpRta+ksD7cIE6HbsDqJeNHId/soAE+xR8FzWRjbbVmjsVtOsBwRjwZHeiaHav8Cy/9
         lcLrOxKWEjZKafCMUYwxM6W6qwIJ1Np4rIXYHVQ7ooHAZEFML6CGz4qcFij98FHRU9UC
         u/Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=LCTRL8N26w6VeA+ALDoKaNaBw3BD9ZLmf399vjPkAeY=;
        b=ZUkZh+lEqRl97YpNgZuD6HXl+ci7S28lPFfi9WbXCPhJ3fOEPPswRd9ZawoEkto2BZ
         FlTMUcR+wcUlhk873mWMALhM+5e7TSPqhTvf983p/Pn1y5RqN0CcoGPa96XSgiWJBJ6A
         Kr32dJYMgK6XIULQywCT6i8jW3JfmoX3cU/J4cjYbjeM2B/Bo1I67utaHmtyGC5yL7CT
         t95MWQIWsBm34fu19y6VrWCcb7libKDyi2eyEaIeR5cgQUj+sg8MX/eNAJV3t1Guqe1c
         2hMuWJV3l5KvH4seC3ebb3Obkueby3WUVe81sCaRjyKzicIS05fThh7h3mbWlMAAb72p
         ut7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f30si8737848plf.393.2019.02.17.16.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Feb 2019 16:52:01 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Feb 2019 16:52:00 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,382,1544515200"; 
   d="scan'208";a="115707640"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by orsmga007.jf.intel.com with ESMTP; 17 Feb 2019 16:51:57 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  Tim Chen <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,  Jérôme Glisse <jglisse@redhat.com>,  Andrea Arcangeli <aarcange@redhat.com>,  David Rientjes <rientjes@google.com>,  Rik van Riel <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang <dave.jiang@intel.com>,  Daniel Jordan <daniel.m.jordan@oracle.com>,  Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190214143318.GJ4525@dhcp22.suse.cz>
	<871s49bkaz.fsf@yhuang-dev.intel.com>
	<20190215131122.GA4525@dhcp22.suse.cz>
Date: Mon, 18 Feb 2019 08:51:55 +0800
In-Reply-To: <20190215131122.GA4525@dhcp22.suse.cz> (Michal Hocko's message of
	"Fri, 15 Feb 2019 14:11:22 +0100")
Message-ID: <87bm39apg4.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko <mhocko@kernel.org> writes:

> On Fri 15-02-19 15:08:36, Huang, Ying wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>> > On Mon 11-02-19 16:38:46, Huang, Ying wrote:
>> >> From: Huang Ying <ying.huang@intel.com>
>> >> 
>> >> When swapin is performed, after getting the swap entry information from
>> >> the page table, system will swap in the swap entry, without any lock held
>> >> to prevent the swap device from being swapoff.  This may cause the race
>> >> like below,
>> >> 
>> >> CPU 1				CPU 2
>> >> -----				-----
>> >> 				do_swap_page
>> >> 				  swapin_readahead
>> >> 				    __read_swap_cache_async
>> >> swapoff				      swapcache_prepare
>> >>   p->swap_map = NULL		        __swap_duplicate
>> >> 					  p->swap_map[?] /* !!! NULL pointer access */
>> >> 
>> >> Because swapoff is usually done when system shutdown only, the race may
>> >> not hit many people in practice.  But it is still a race need to be fixed.
>> >> 
>> >> To fix the race, get_swap_device() is added to check whether the specified
>> >> swap entry is valid in its swap device.  If so, it will keep the swap
>> >> entry valid via preventing the swap device from being swapoff, until
>> >> put_swap_device() is called.
>> >> 
>> >> Because swapoff() is very rare code path, to make the normal path runs as
>> >> fast as possible, disabling preemption + stop_machine() instead of
>> >> reference count is used to implement get/put_swap_device().  From
>> >> get_swap_device() to put_swap_device(), the preemption is disabled, so
>> >> stop_machine() in swapoff() will wait until put_swap_device() is called.
>> >> 
>> >> In addition to swap_map, cluster_info, etc.  data structure in the struct
>> >> swap_info_struct, the swap cache radix tree will be freed after swapoff,
>> >> so this patch fixes the race between swap cache looking up and swapoff
>> >> too.
>> >> 
>> >> Races between some other swap cache usages protected via disabling
>> >> preemption and swapoff are fixed too via calling stop_machine() between
>> >> clearing PageSwapCache() and freeing swap cache data structure.
>> >> 
>> >> Alternative implementation could be replacing disable preemption with
>> >> rcu_read_lock_sched and stop_machine() with synchronize_sched().
>> >
>> > using stop_machine is generally discouraged. It is a gross
>> > synchronization.
>> >
>> > Besides that, since when do we have this problem?
>> 
>> For problem, you mean the race between swapoff and the page fault
>> handler?
>
> yes
>
>> The problem is introduced in v4.11 when we avoid to replace
>> swap_info_struct->lock with swap_cluster_info->lock in
>> __swap_duplicate() if possible to improve the scalability of swap
>> operations.  But because swapoff is a really rare operation, I don't
>> think it's necessary to backport the fix.
>
> Well, a lack of any bug reports would support your theory that this is
> unlikely to hit in practice. Fixes tag would be nice to have regardless
> though.

Sure.  Will add "Fixes" tag.

Best Regards,
Huang, Ying

> Thanks!

