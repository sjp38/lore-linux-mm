Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id D93386B0068
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 10:51:23 -0500 (EST)
Message-ID: <50B38F69.6020902@zytor.com>
Date: Mon, 26 Nov 2012 07:48:57 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] page_alloc: Bootmem limit with movablecore_map
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-6-git-send-email-tangchen@cn.fujitsu.com> <50B36354.7040501@gmail.com> <50B36B54.7050506@cn.fujitsu.com>
In-Reply-To: <50B36B54.7050506@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: wujianguo <wujianguo106@gmail.com>, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, wujianguo@huawei.com, qiuxishi@huawei.com

On 11/26/2012 05:15 AM, Tang Chen wrote:
> 
> Hi Wu,
> 
> That is really a problem. And, before numa memory got initialized,
> memblock subsystem would be used to allocate memory. I didn't find any
> approach that could fully address it when I making the patches. There
> always be risk that memblock allocates memory on ZONE_MOVABLE. I think
> we can only do our best to prevent it from happening.
> 
> Your patch is very helpful. And after a shot look at the code, it seems
> that acpi_numa_memory_affinity_init() is an architecture dependent
> function. Could we do this somewhere which is not depending on the
> architecture ?
> 

The movable memory should be classified as a non-RAM type in memblock,
that way we will not allocate from it early on.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
