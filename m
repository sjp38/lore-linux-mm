Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A1F676B0072
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 07:07:40 -0500 (EST)
Message-ID: <50F00052.80809@cn.fujitsu.com>
Date: Fri, 11 Jan 2013 20:06:42 +0800
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



On 01/11/2013 06:47 PM, Michal Hocko wrote:
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index ddd3b58..d8edf52 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -32,6 +32,7 @@
>  #include <linux/memory_hotplug.h>
>  #include <linux/nmi.h>
>  #include <linux/gfp.h>
> +#include <linux/memory_hotplug.h>
except for this,

Tested-by: Lin Feng <linfeng@cn.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
