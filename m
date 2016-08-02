Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C995828E1
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:48:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so329042129pfd.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:48:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id h2si2976452paz.181.2016.08.02.05.48.04
        for <linux-mm@kvack.org>;
        Tue, 02 Aug 2016 05:48:04 -0700 (PDT)
Date: Tue, 2 Aug 2016 20:48:00 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [   25.666092] WARNING: CPU: 0 PID: 451 at mm/memcontrol.c:998
 mem_cgroup_update_lru_size
Message-ID: <20160802124800.GA1475@wfg-t540p.sh.intel.com>
References: <20160801013830.GB27998@wfg-t540p.sh.intel.com>
 <20160802082243.GE2693@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160802082243.GE2693@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKP <lkp@01.org>

Hi Mel,

On Tue, Aug 02, 2016 at 09:22:43AM +0100, Mel Gorman wrote:
>On Mon, Aug 01, 2016 at 09:38:30AM +0800, Fengguang Wu wrote:
>> Greetings,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git mm-vmscan-node-lru-follow-up-v2r1
>>
>> commit d5d54a2c5517f0818ad75a2f5b1d26a0dacae46a
>> Author:     Mel Gorman <mgorman@techsingularity.net>
>> AuthorDate: Wed Jul 13 09:30:01 2016 +0100
>> Commit:     Mel Gorman <mgorman@techsingularity.net>
>> CommitDate: Wed Jul 13 09:30:01 2016 +0100
>>
>
>That bug is addressed later in the tree by "mm, vmscan: Update all zone
>LRU sizes before updating memcg". Is the warning visible in the latest
>mainline tree?

Yes that warning no longer show up in branch
"mm-vmscan-node-lru-follow-up-v2r1" HEAD.

Mainline kernel is also fine. I should have checked these,
sorry for the noise!

Regards,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
