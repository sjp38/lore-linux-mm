Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2B0D76B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 07:39:20 -0500 (EST)
Message-ID: <50F007C9.10606@cn.fujitsu.com>
Date: Fri, 11 Jan 2013 20:38:33 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mmots: memory-hotplug: implement register_page_bootmem_info_section
 of sparse-vmemmap fix
References: <20130111095658.GC7286@dhcp22.suse.cz> <20130111101745.GD7286@dhcp22.suse.cz> <20130111102924.GE7286@dhcp22.suse.cz> <20130111104759.GF7286@dhcp22.suse.cz> <50F00041.2040305@cn.fujitsu.com> <20130111121226.GI7286@dhcp22.suse.cz>
In-Reply-To: <20130111121226.GI7286@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wu Jianguo <wujianguo@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/11/2013 08:12 PM, Michal Hocko wrote:
> On Fri 11-01-13 20:06:25, Tang Chen wrote:
>> On 01/11/2013 06:47 PM, Michal Hocko wrote:
>>>>
>>>> Darn! And now that I am looking at the patch closer it is too x86
>>>> centric so this cannot be in the generic code. I will try to cook
>>>> something better. Sorry about the noise.
>>>
>>> It is more complicated than I thought. One would tell it's a mess.
>>> The patch bellow fixes the compilation issue but I am not sure we want
>>> to include memory_hotplug.h into arch/x86/mm/init_64.c. Moreover
>>>
>>> +void register_page_bootmem_memmap(unsigned long section_nr,
>>> +				  struct page *start_page, unsigned long size)
>>> +{
>>> +	/* TODO */
>>> +}
>>>
>>> for other archs would suggest that the code is not ready yet. Should
>>> this rather be dropped for now?
>>
>> Hi Michal,
>>
>> Do you mean remove register_page_bootmem_memmap() from other
>> architectures ?
>
> No I meant the patch to be dropped until it gets implementation for
> other architectures or the users of the function would be explicit about
> archs which are supported. What happens if the implementation is empty
> will the generic code work properly? From my very limitted understanding
> of the code it won't.

Hi Michal,

Hum, I see. Thank you for your remind. :)
register_page_bootmem_info_section() will be different in other
architectures if register_page_bootmem_memmap() is empty.

I think we can post a patch to make register_page_bootmem_info_section()
the same as before, and we just implement the x86 version first. So that
it will have no harm to other architectures.

How do you think ?

Thanks. :)

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
