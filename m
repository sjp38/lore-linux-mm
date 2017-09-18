Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2580A6B0038
	for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:08:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f84so13625510pfj.0
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 20:08:40 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v8si4502208plp.435.2017.09.17.20.08.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 20:08:39 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: Handle numa statistics distinctively based-on
 different VM stats modes
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-3-git-send-email-kemi.wang@intel.com>
 <20170915115049.vqthfawg3y4r6ogh@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <26bd25c8-294f-d3cc-8ba2-845a6da33fe5@intel.com>
Date: Mon, 18 Sep 2017 11:07:20 +0800
MIME-Version: 1.0
In-Reply-To: <20170915115049.vqthfawg3y4r6ogh@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, kemi <kemi.wang@intel.com>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'09ae??15ae?JPY 19:50, Michal Hocko wrote:
> On Fri 15-09-17 17:23:25, Kemi Wang wrote:
> [...]
>> @@ -2743,6 +2745,17 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
>>  #ifdef CONFIG_NUMA
>>  	enum numa_stat_item local_stat = NUMA_LOCAL;
>>  
>> +	/*
>> +	 * skip zone_statistics() if vmstat is a coarse mode or zone statistics
>> +	 * is inactive in auto vmstat mode
>> +	 */
>> +
>> +	if (vmstat_mode) {
>> +		if (vmstat_mode == VMSTAT_COARSE_MODE)
>> +			return;
>> +	} else if (disable_zone_statistics)
>> +		return;
>> +
>>  	if (z->node != numa_node_id())
>>  		local_stat = NUMA_OTHER;
> 
> A jump label could make this completely out of the way for the case
> where every single cycle matters.
> 

Could you be more explicit for how to implement it here. Thanks very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
