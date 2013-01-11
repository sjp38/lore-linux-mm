Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 97CF96B006C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 06:09:57 -0500 (EST)
Message-ID: <50EFF2CB.8060206@cn.fujitsu.com>
Date: Fri, 11 Jan 2013 19:08:59 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mmots: memory-hotplug: implement register_page_bootmem_info_section
 of sparse-vmemmap fix
References: <20130111095658.GC7286@dhcp22.suse.cz> <20130111101745.GD7286@dhcp22.suse.cz> <20130111102924.GE7286@dhcp22.suse.cz> <20130111104759.GF7286@dhcp22.suse.cz>
In-Reply-To: <20130111104759.GF7286@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wu Jianguo <wujianguo@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Michal,

On 01/11/2013 06:47 PM, Michal Hocko wrote:
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  arch/x86/mm/init_64.c |    3 +++
>  include/linux/mm.h    |    2 ++
>  2 files changed, 5 insertions(+)
> 
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index ddd3b58..d8edf52 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -32,6 +32,7 @@
>  #include <linux/memory_hotplug.h>
linux/memory_hotplug.h has already been included here.

I think it's OK to add add the missing CONFIG option or move
the memory-hotlug related complaint code into the CONFIG span. 

thanks,
linfeng
>  #include <linux/nmi.h>
>  #include <linux/gfp.h>
> +#include <linux/memory_hotplug.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
