Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E96C76B0070
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 22:28:47 -0500 (EST)
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C95FF53@ORSMSX108.amr.corp.intel.com>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B5CFAE.80103@huawei.com> <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com> <50B68467.5020008@zytor.com> <20121129110045.GX8218@suse.de> <3908561D78D1C84285E8C5FCA982C28F1C95FF53@ORSMSX108.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: RE: [PATCH v2 0/5] Add movablecore_map boot option
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 29 Nov 2012 19:28:12 -0800
Message-ID: <5a01986b-e412-44df-b376-fce7f8937b93@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Mel Gorman <mgorman@suse.de>
Cc: Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

Disk I/O is still a big consumer of lowmem.

"Luck, Tony" <tony.luck@intel.com> wrote:

>> If any significant percentage of memory is in ZONE_MOVABLE then the
>memory
>> hotplug people will have to deal with all the lowmem/highmem problems
>> that used to be faced by 32-bit x86 with PAE enabled. 
>
>While these problems may still exist on large systems - I think it
>becomes
>harder to construct workloads that run into problems.  In those bad old
>days
>a significant fraction of lowmem was consumed by the kernel ... so it
>was
>pretty easy to find meta-data intensive workloads that would push it
>over
>a cliff.  Here we  are talking about systems with say 128GB per node
>divided
>into 64GB moveable and 64GB non-moveable (and I'd regard this as a
>rather
>low-end machine).  Unless the workload consists of zillions of tiny
>processes
>all mapping shared memory blocks, the percentage of memory allocated to
>the kernel is going to be tiny compared with the old 4GB days.
>
>-Tony

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
