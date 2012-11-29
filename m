Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 9ADC16B005A
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 05:39:17 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BB56D3EE0C1
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 19:39:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EB0145DE60
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 19:39:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 71F7E45DE59
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 19:39:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 625761DB8057
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 19:39:15 +0900 (JST)
Received: from g01jpexchyt30.g01.fujitsu.local (g01jpexchyt30.g01.fujitsu.local [10.128.193.113])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C1E01DB8050
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 19:39:15 +0900 (JST)
Message-ID: <50B73B22.90500@jp.fujitsu.com>
Date: Thu, 29 Nov 2012 19:38:26 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B5CFAE.80103@huawei.com> <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

Hi Tony,

2012/11/29 6:34, Luck, Tony wrote:
>> 1. use firmware information
>>    According to ACPI spec 5.0, SRAT table has memory affinity structure
>>    and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
>>    Affinity Structure". If we use the information, we might be able to
>>    specify movable memory by firmware. For example, if Hot Pluggable
>>    Filed is enabled, Linux sets the memory as movable memory.
>>
>> 2. use boot option
>>    This is our proposal. New boot option can specify memory range to use
>>    as movable memory.
>
> Isn't this just moving the work to the user? To pick good values for the

Yes.

> movable areas, they need to know how the memory lines up across
> node boundaries ... because they need to make sure to allow some
> non-movable memory allocations on each node so that the kernel can
> take advantage of node locality.

There is no problem.
Linux has already two boot options, kernelcore= and movablecore=.
So if we use them, non-movable memory is divided into each node evenly.

But there is no way to specify a node used as movable currently. So
we proposed the new boot option.

> So the user would have to read at least the SRAT table, and perhaps
> more, to figure out what to provide as arguments.
>

> Since this is going to be used on a dynamic system where nodes might
> be added an removed - the right values for these arguments might
> change from one boot to the next. So even if the user gets them right
> on day 1, a month later when a new node has been added, or a broken
> node removed the values would be stale.

I don't think so. Even if we hot add/remove node, the memory range of
each memory device is not changed. So we don't need to change the boot
option.

Thanks,
Yasuaki Ishimatsu

>
> -Tony
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
