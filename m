Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57AA36B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 01:06:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q75so13914699pfl.1
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 22:06:36 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id r9si4091018pge.637.2017.09.17.22.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 22:06:35 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: Handle numa statistics distinctively based-on
 different VM stats modes
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-3-git-send-email-kemi.wang@intel.com>
 <20170915115049.vqthfawg3y4r6ogh@dhcp22.suse.cz>
 <26bd25c8-294f-d3cc-8ba2-845a6da33fe5@intel.com>
 <1bd90605-c765-ca27-b8ee-ca803a8bcdea@linux.intel.com>
From: kemi <kemi.wang@intel.com>
Message-ID: <21090d5e-f8be-731f-75bc-b01bf53409b2@intel.com>
Date: Mon, 18 Sep 2017 13:05:17 +0800
MIME-Version: 1.0
In-Reply-To: <1bd90605-c765-ca27-b8ee-ca803a8bcdea@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'09ae??18ae?JPY 12:13, Dave Hansen wrote:
> On 09/17/2017 08:07 PM, kemi wrote:
>>>> +	if (vmstat_mode) {
>>>> +		if (vmstat_mode == VMSTAT_COARSE_MODE)
>>>> +			return;
>>>> +	} else if (disable_zone_statistics)
>>>> +		return;
>>>> +
>>>>  	if (z->node != numa_node_id())
>>>>  		local_stat = NUMA_OTHER;
>>>
>>> A jump label could make this completely out of the way for the case
>>> where every single cycle matters.
>>
>> Could you be more explicit for how to implement it here. Thanks very much.
> 
> Take a look at include/linux/jump_label.h.
> 
> 

Sure, Thanks

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
