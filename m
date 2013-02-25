Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C729D6B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 04:02:02 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id v40so1385560dad.4
        for <linux-mm@kvack.org>; Mon, 25 Feb 2013 01:02:01 -0800 (PST)
Message-ID: <512B287E.3020902@gmail.com>
Date: Mon, 25 Feb 2013 17:01:50 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH 1/2] acpi, movablemem_map: Exclude memblock.reserved
 ranges when parsing SRAT.
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com> <1361358056-1793-2-git-send-email-tangchen@cn.fujitsu.com> <5124C22B.8030401@cn.fujitsu.com> <5124C32E.1080902@gmail.com> <3908561D78D1C84285E8C5FCA982C28F1E06B55D@ORSMSX108.amr.corp.intel.com> <512564B1.8020008@gmail.com> <3908561D78D1C84285E8C5FCA982C28F1E06B636@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1E06B636@ORSMSX108.amr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "hpa@zytor.com" <hpa@zytor.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/21/2013 08:23 AM, Luck, Tony wrote:
>> Thanks for your clarify. What's the relationship between memory ranges
>> and address ranges here?
> The ranges in the SRAT table might cover more memory than is present on
> the system.  E.g. on some large Itanium systems the SRAT table would say
> that 0-1TB was on node0, 1-2TB on node1, etc.
>
> The EFI memory map described the memory actually present (perhaps just
> a handful of GB on each node).
>
> X86 systems tend not to have such radically sparse layouts, so this may be less
> of a distinction.
>
>> What's the relationship between memory/address ranges and /proc/iomem?
> I *think* that /proc/iomem just shows what is in e820 (for the memory entries,
> it also adds in I/O ranges that come from other ACPI sources).

When I setup a new e820 range through memmap, system hung during boot. 
Is there limit when setup memmap?

>
> -Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
