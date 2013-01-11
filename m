Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9ED476B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 07:07:15 -0500 (EST)
Message-ID: <50F00041.2040305@cn.fujitsu.com>
Date: Fri, 11 Jan 2013 20:06:25 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mmots: memory-hotplug: implement register_page_bootmem_info_section
 of sparse-vmemmap fix
References: <20130111095658.GC7286@dhcp22.suse.cz> <20130111101745.GD7286@dhcp22.suse.cz> <20130111102924.GE7286@dhcp22.suse.cz> <20130111104759.GF7286@dhcp22.suse.cz>
In-Reply-To: <20130111104759.GF7286@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wu Jianguo <wujianguo@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/11/2013 06:47 PM, Michal Hocko wrote:
>>
>> Darn! And now that I am looking at the patch closer it is too x86
>> centric so this cannot be in the generic code. I will try to cook
>> something better. Sorry about the noise.
>
> It is more complicated than I thought. One would tell it's a mess.
> The patch bellow fixes the compilation issue but I am not sure we want
> to include memory_hotplug.h into arch/x86/mm/init_64.c. Moreover
>
> +void register_page_bootmem_memmap(unsigned long section_nr,
> +				  struct page *start_page, unsigned long size)
> +{
> +	/* TODO */
> +}
>
> for other archs would suggest that the code is not ready yet. Should
> this rather be dropped for now?

Hi Michal,

Do you mean remove register_page_bootmem_memmap() from other
architectures ?  Well, I think this function is called by
register_page_bootmem_info_section(), which is a common function
in mm/memory_hotplug.c shared by all architectures. So I don't think
we should remove it. :)

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
