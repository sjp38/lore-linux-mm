Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 35E686B0072
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 20:21:09 -0500 (EST)
Message-ID: <50B41573.4020205@zytor.com>
Date: Mon, 26 Nov 2012 17:20:51 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] page_alloc: Bootmem limit with movablecore_map
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-6-git-send-email-tangchen@cn.fujitsu.com> <50B36354.7040501@gmail.com> <50B36B54.7050506@cn.fujitsu.com> <50B38F69.6020902@zytor.com> <50B41395.60808@huawei.com>
In-Reply-To: <50B41395.60808@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, wujianguo <wujianguo106@gmail.com>, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, wujianguo@huawei.com, qiuxishi@huawei.com, Len Brown <lenb@kernel.org>

On 11/26/2012 05:12 PM, Jiang Liu wrote:
> Hi Peter,
>
> I have tried to reserved movable memory from bootmem allocator, but the
> ACPICA subsystem is initialized later than setting up movable zone.
> So still trying to figure out a way to setup/reserve movable zones
> according to information from static ACPI tables such as SRAT/MPST etc.
>

[Adding Len Brown]

Right, for the case of platform-configured memory.  Len, I'm wondering 
if there is any reasonable way we can get memory-map-related stuff out 
of ACPI before we initialize the full ACPICA... we could of course write 
an ad hoc static parser (these are just static tables, after all), but 
I'm not sure if that fits into your overall view of how the subsystem 
should work?

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
