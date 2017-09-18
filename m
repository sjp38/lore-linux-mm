Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA7326B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 00:13:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 188so15738106pgb.3
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 21:13:17 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u79si4030110pgb.585.2017.09.17.21.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 21:13:16 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: Handle numa statistics distinctively based-on
 different VM stats modes
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-3-git-send-email-kemi.wang@intel.com>
 <20170915115049.vqthfawg3y4r6ogh@dhcp22.suse.cz>
 <26bd25c8-294f-d3cc-8ba2-845a6da33fe5@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <1bd90605-c765-ca27-b8ee-ca803a8bcdea@linux.intel.com>
Date: Sun, 17 Sep 2017 21:13:13 -0700
MIME-Version: 1.0
In-Reply-To: <26bd25c8-294f-d3cc-8ba2-845a6da33fe5@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 09/17/2017 08:07 PM, kemi wrote:
>>> +	if (vmstat_mode) {
>>> +		if (vmstat_mode == VMSTAT_COARSE_MODE)
>>> +			return;
>>> +	} else if (disable_zone_statistics)
>>> +		return;
>>> +
>>>  	if (z->node != numa_node_id())
>>>  		local_stat = NUMA_OTHER;
>>
>> A jump label could make this completely out of the way for the case
>> where every single cycle matters.
> 
> Could you be more explicit for how to implement it here. Thanks very much.

Take a look at include/linux/jump_label.h.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
