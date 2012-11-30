Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 049396B0074
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 21:59:04 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v2 0/5] Add movablecore_map boot option
Date: Fri, 30 Nov 2012 02:58:40 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1C95FF53@ORSMSX108.amr.corp.intel.com>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
 <50B5CFAE.80103@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com>
 <50B68467.5020008@zytor.com> <20121129110045.GX8218@suse.de>
In-Reply-To: <20121129110045.GX8218@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

> If any significant percentage of memory is in ZONE_MOVABLE then the memor=
y
> hotplug people will have to deal with all the lowmem/highmem problems
> that used to be faced by 32-bit x86 with PAE enabled.=20

While these problems may still exist on large systems - I think it becomes
harder to construct workloads that run into problems.  In those bad old day=
s
a significant fraction of lowmem was consumed by the kernel ... so it was
pretty easy to find meta-data intensive workloads that would push it over
a cliff.  Here we  are talking about systems with say 128GB per node divide=
d
into 64GB moveable and 64GB non-moveable (and I'd regard this as a rather
low-end machine).  Unless the workload consists of zillions of tiny process=
es
all mapping shared memory blocks, the percentage of memory allocated to
the kernel is going to be tiny compared with the old 4GB days.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
