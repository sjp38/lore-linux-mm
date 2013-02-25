Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id AD7A36B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 22:35:36 -0500 (EST)
Message-ID: <512ADB52.9040008@cn.fujitsu.com>
Date: Mon, 25 Feb 2013 11:32:34 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH 1/2] acpi, movablemem_map: Exclude memblock.reserved
 ranges when parsing SRAT.
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com> <1361358056-1793-2-git-send-email-tangchen@cn.fujitsu.com> <5124C22B.8030401@cn.fujitsu.com> <5124C32E.1080902@gmail.com> <3908561D78D1C84285E8C5FCA982C28F1E06B55D@ORSMSX108.amr.corp.intel.com> <512ABFF7.9090207@gmail.com>
In-Reply-To: <512ABFF7.9090207@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "hpa@zytor.com" <hpa@zytor.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/25/2013 09:35 AM, Will Huck wrote:
> On 02/21/2013 06:41 AM, Luck, Tony wrote:
>>> What's the relationship between e820 map and SRAT?
>> The e820 map (or EFI memory map on some recent systems) provides
>> a list of memory ranges together with usage information (e.g. reserved
>> for BIOS, or available) and attributes (WB cacheable, uncacheable).
>>
>> The SRAT table provides topology information for address ranges. It
>> tells the OS which memory is close to each cpu, and which is more
>> distant. If there are multiple degrees of "distant" then the SLIT table
>> provides a matrix of relative latencies between nodes.
>
> What's the meaning of multiple degrees of "distant" here? Eg, there are
> ten nodes, can SRAT tell each node which memory on other node is more
> close or distant? If the answer is yes, why need SLIT since processes
> can use memory close to their nodes.

Hi Will

Referring to the ACPI spec, SRAT provides info of each node, and SLIT
provides info between nodes and nodes, I think.

SRAT provides number of CPUs and memory of node i, memory range, the PXM 
id which
will be mapped to node id, and hotplug info, and so on.

SLIT provides a matrix describing the distances between node i and node j.

>
>
> SRAT and SLIT are get from firmware or UEFI?
>
I think we can get this info from ACPI BIOS.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
