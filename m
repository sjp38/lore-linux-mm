Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id DC6A86B000A
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 01:44:44 -0500 (EST)
Message-ID: <51076FAC.9060605@cn.fujitsu.com>
Date: Tue, 29 Jan 2013 14:43:56 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] acpi, memory-hotplug: Support getting hotplug info
 from SRAT.
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com> <1359106929-3034-4-git-send-email-tangchen@cn.fujitsu.com> <20130125171230.34c5a273.akpm@linux-foundation.org> <51033186.3000706@zytor.com> <5105DD4B.9020901@cn.fujitsu.com> <3908561D78D1C84285E8C5FCA982C28F1C98F9CB@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C98F9CB@ORSMSX108.amr.corp.intel.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/29/2013 01:45 AM, Luck, Tony wrote:
>> I will post a patch to fix it. How about always keep node0 unhotpluggable ?
>
> Node 0 (or more specifically the node that contains memory<4GB) will be
> full of BIOS reserved holes in the memory map.

Hi Tony,

One thing I'm not sure, is memory<4GB always on node 0 ?
On my box, it is on node 0.

But since node id is 1-1 mapped to PXM in SRAT, if SRAT entries are not 
ordered by
physical address, memory<4GB may not on node 0. I think this is 
something related
to firmware. i didn't find anything about the order problem in ACPI 
specification.

So, do we just check if the node id != 0, or we need to check if we have 
reserved
enough for kernel, such as 4GB ?

Thanks. :)

>It probably isn't removable
> even if Linux thinks it is.  Someday we might have a smart BIOS that can
> relocate itself to another node - but for now making node0 unhotpluggable
> looks to be a plausible interim move.
>
> Ultimately we'd like to be able to remove any node (just not all of them at
> the same time ... just like we can now offline any cpu - but not all of them
> together).
>
> -Tony
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
