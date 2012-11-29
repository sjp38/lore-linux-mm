Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 5C8926B0068
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 10:54:18 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so6922226pad.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 07:54:17 -0800 (PST)
Message-ID: <50B784F9.4030105@gmail.com>
Date: Thu, 29 Nov 2012 23:53:29 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B5CFAE.80103@huawei.com> <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com> <50B73B22.90500@jp.fujitsu.com>
In-Reply-To: <50B73B22.90500@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

Hi Yasuaki,
	Forgot to mention that I have no objection to this patchset.
I think it's a good start point, but we still need to improve usabilities
of memory hotplug by passing platform specific information from BIOS.
And mechanism provided by this patchset will/may be used to improve
usabilities too. 

Regards!
Gerry

On 11/29/2012 06:38 PM, Yasuaki Ishimatsu wrote:
> Hi Tony,
> 
> 2012/11/29 6:34, Luck, Tony wrote:
>>> 1. use firmware information
>>>    According to ACPI spec 5.0, SRAT table has memory affinity structure
>>>    and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
>>>    Affinity Structure". If we use the information, we might be able to
>>>    specify movable memory by firmware. For example, if Hot Pluggable
>>>    Filed is enabled, Linux sets the memory as movable memory.
>>>
>>> 2. use boot option
>>>    This is our proposal. New boot option can specify memory range to use
>>>    as movable memory.
>>
>> Isn't this just moving the work to the user? To pick good values for the
> 
> Yes.
> 
>> movable areas, they need to know how the memory lines up across
>> node boundaries ... because they need to make sure to allow some
>> non-movable memory allocations on each node so that the kernel can
>> take advantage of node locality.
> 
> There is no problem.
> Linux has already two boot options, kernelcore= and movablecore=.
> So if we use them, non-movable memory is divided into each node evenly.
> 
> But there is no way to specify a node used as movable currently. So
> we proposed the new boot option.
> 
>> So the user would have to read at least the SRAT table, and perhaps
>> more, to figure out what to provide as arguments.
>>
> 
>> Since this is going to be used on a dynamic system where nodes might
>> be added an removed - the right values for these arguments might
>> change from one boot to the next. So even if the user gets them right
>> on day 1, a month later when a new node has been added, or a broken
>> node removed the values would be stale.
> 
> I don't think so. Even if we hot add/remove node, the memory range of
> each memory device is not changed. So we don't need to change the boot
> option.
> 
> Thanks,
> Yasuaki Ishimatsu
> 
>>
>> -Tony
>>
> 
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
