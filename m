Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 549A66B00C1
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:37:03 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so532856pbc.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 07:37:02 -0800 (PST)
Message-ID: <50B8D288.4080204@gmail.com>
Date: Fri, 30 Nov 2012 23:36:40 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B5CFAE.80103@huawei.com> <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com> <50B68467.5020008@zytor.com> <20121129110045.GX8218@suse.de> <50B82064.9000405@huawei.com> <50B824DE.40702@jp.fujitsu.com>
In-Reply-To: <50B824DE.40702@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, "Luck, Tony" <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

On 11/30/2012 11:15 AM, Yasuaki Ishimatsu wrote:
> Hi Jiang,
> 
>>
>> For the first issue, I think we could automatically convert pages
>> from movable zones into normal zones. Congyan from Fujitsu has provided
>> a patchset to manually convert pages from movable zones into normal zones,
>> I think we could extend that mechanism to automatically convert when
>> normal zones are under pressure by hooking into the slow page allocation
>> path.
>>
>> We rely on hardware features to solve the second and third issues.
>> Some new platforms provide a new RAS feature called "hardware memory
>> migration", which transparent migrate memory from one memory device
>> to another. With hardware memory migration, we could configure one
>> memory device on a NUMA node to host normal zone, and the other memory
>> devices to host movable zone. By this configuration, it won't cause
>> performance drop because each NUMA node still has local normal zone.
>> When trying to remove a memory device hosting normal zone, we just
>> need to find another spare memory device and use hardware memory migration
>> to transparently migrate memory content to the spare one. The drawback
>> is we have strong dependency on hardware features so it's not a common
>> solution for all architectures.
> 
> I agree with you. If BIOS and hardware support memory hotplug, OS should
> use them. But if OS cannot use them, we need to solve in OS. I think
> that our proposal which used ZONE_MOVABLE is first step for supporting
> memory hotplug.
Hi Yasuaki,
	It's true, we should start with first step then improve it.
Regards!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
