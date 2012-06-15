Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D43C06B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 02:11:12 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 11:41:08 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5F6Ahxs53215300
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 11:40:43 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FBfC2l028112
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 21:41:12 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
In-Reply-To: <20120614141257.GQ27397@tiehlicka.suse.cz>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120614141257.GQ27397@tiehlicka.suse.cz>
Date: Fri, 15 Jun 2012 11:40:24 +0530
Message-ID: <87pq91m7fz.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

Michal Hocko <mhocko@suse.cz> writes:

> On Thu 14-06-12 19:26:18, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  include/linux/hugetlb.h |    2 +-
>>  mm/hugetlb.c            |    2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 9650bb1..0f0877e 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -23,7 +23,7 @@ struct hugepage_subpool {
>>  };
>>  
>>  extern spinlock_t hugetlb_lock;
>> -extern int hugetlb_max_hstate;
>> +extern int hugetlb_max_hstate __read_mostly;
>
> It should be used only for definition
>
I looked at the rest of the source and found multiple place where we
specify __read_mostly in extern.

arch/x86/kernel/cpu/perf_event.h extern struct x86_pmu x86_pmu __read_mostly;
arch/x86/kernel/cpu/perf_event.h extern u64 __read_mostly hw_cache_event_ids
arch/x86/kernel/cpu/perf_event.h extern u64 __read_mostly hw_cache_extra_regs

drivers/gpu/drm/i915/i915_drv.h extern int i915_panel_ignore_lid __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern unsigned int i915_powersave __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern int i915_semaphores __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern unsigned int i915_lvds_downclock __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern int i915_lvds_channel_mode __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern int i915_panel_use_ssc __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern int i915_vbt_sdvo_panel_type __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern int i915_enable_rc6 __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern int i915_enable_fbc __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern bool i915_enable_hangcheck __read_mostly;
drivers/gpu/drm/i915/i915_drv.h extern int i915_enable_ppgtt __read_mostly;

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
