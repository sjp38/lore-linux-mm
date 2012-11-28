Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id DA3E16B006C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 00:17:55 -0500 (EST)
Message-ID: <50B59E54.9090107@huawei.com>
Date: Wed, 28 Nov 2012 13:17:08 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B42F32.4050107@gmail.com> <50B58965.7040703@cn.fujitsu.com> <50B58CA9.9010606@huawei.com> <50B59F5B.5030400@cn.fujitsu.com>
In-Reply-To: <50B59F5B.5030400@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, wujianguo <wujianguo106@gmail.com>, hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 2012-11-28 13:21, Wen Congyang wrote:
> At 11/28/2012 12:01 PM, Jiang Liu Wrote:
>> On 2012-11-28 11:47, Tang Chen wrote:
>>> On 11/27/2012 11:10 AM, wujianguo wrote:
>>>>
>>>> Hi Tang,
>>>>     DMA address can't be set as movable, if some one boot kernel with
>>>> movablecore_map=4G@0xa00000 or other memory region that contains DMA address,
>>>> system maybe boot failed. Should this case be handled or mentioned
>>>> in the change log and kernel-parameters.txt?
>>>
>>> Hi Wu,
>>>
>>> I think we can use MAX_DMA_PFN and MAX_DMA32_PFN to prevent setting DMA
>>> address as movable. Just ignore the address lower than them, and set
>>> the rest as movable. How do you think ?
>>>
>>> And, since we cannot figure out the minimum of memory kernel needs, I
>>> think for now, we can just add some warning into kernel-parameters.txt.
>>>
>>> Thanks. :)
>> On one other OS, there is a mechanism to dynamically convert pages from
>> movable zones into normal zones.
> 
> The OS auto does it? Or the user coverts it?
> 
> We can convert pages from movable zones into normal zones by the following
> interface:
> echo online_kernel >/sys/devices/system/memory/memoryX/state
> 
> We have posted a patchset to implement it, and it is in mm tree now.
OS automatically converts it, no manual operations needed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
