Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0551D6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:44:27 -0400 (EDT)
Received: by ieqy10 with SMTP id y10so118034247ieq.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:44:26 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id hb10si36926190icc.42.2015.06.29.08.44.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 08:44:26 -0700 (PDT)
Received: by iebmu5 with SMTP id mu5so117544754ieb.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:44:26 -0700 (PDT)
Message-ID: <559167D8.80803@gmail.com>
Date: Mon, 29 Jun 2015 11:44:24 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function alloc_mem_cgroup_per_zone_info bool
References: <1435587233-27976-1-git-send-email-xerofoify@gmail.com> <20150629150311.GC4612@dhcp22.suse.cz> <3320C010-248A-4296-A5E4-30D9E7B3E611@gmail.com> <20150629153623.GC4617@dhcp22.suse.cz>
In-Reply-To: <20150629153623.GC4617@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2015-06-29 11:36 AM, Michal Hocko wrote:
> On Mon 29-06-15 11:23:08, Nicholas Krause wrote:
> [...]
>> I agree with and looked into the callers about this wasn't sure if you
>> you wanted me to return - ENOMEM.  I will rewrite this patch the other
>> way. 
> 
> I am not sure this path really needs a cleanup.
> 
>> Furthermore I apologize about this and do have actual useful
>> patches but will my rep it's hard to get replies from maintainers.
> 
> You can hardly expect somebody will be thrilled about your patches when
> their fault rate is close to 100%. Reviewing each patch takes time and
> that is a scarce resource. If you want people to follow your patches
> make sure you are offering something that might be interesting or
> useful. Cleanups like these usually are not interesting without
> either building something bigger on top of them or when they improve
> readability considerably.
> 
> [...]
> 
Actually my patch record is much better now it's at the worst case 60% are correct and 40 % are not
and this based on the few that have been merged. Here is a patch series I have been trying to merge
for a bug in the gma500 other the last few patches. There are other patches I have like this lying
around.
Nick 
