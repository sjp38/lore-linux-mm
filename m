Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 394AB6B0069
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 20:41:06 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id y36so10548418plh.10
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 17:41:06 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o32si13792934pld.552.2017.12.20.17.41.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 17:41:05 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm: use node_page_state_snapshot to avoid
 deviation
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-5-git-send-email-kemi.wang@intel.com>
 <20171219124317.GP2787@dhcp22.suse.cz>
 <94187fd5-ad70-eba7-2724-0fe5bed750d6@intel.com>
 <20171220100650.GI4831@dhcp22.suse.cz>
 <1f3a6d05-2756-93fd-a380-df808c94ece8@intel.com>
 <alpine.DEB.2.20.1712200956080.7506@nuc-kabylake>
From: kemi <kemi.wang@intel.com>
Message-ID: <1f0d8933-60a3-e2e0-f7a3-36e98ade48bb@intel.com>
Date: Thu, 21 Dec 2017 09:39:01 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712200956080.7506@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'12ae??20ae?JPY 23:58, Christopher Lameter wrote:
> On Wed, 20 Dec 2017, kemi wrote:
> 
>>> You are making numastats special and I yet haven't heard any sounds
>>> arguments for that. But that should be discussed in the respective
>>> patch.
>>>
>>
>> That is because we have much larger threshold size for NUMA counters, that means larger
>> deviation. So, the number in local cpus may not be simply ignored.
> 
> Some numbers showing the effect of these changes would be helpful. You can
> probably create some in kernel synthetic tests to start with which would
> allow you to see any significant effects of those changes.
> 
> Then run the larger testsuites (f.e. those that Mel has published) and
> benchmarks to figure out how behavior of real apps *may* change?
> 

OK.
I will do that when available.
Let's just drop this patch in this series and consider this issue
in another patch. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
