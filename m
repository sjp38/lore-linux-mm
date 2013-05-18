Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 824AC6B0002
	for <linux-mm@kvack.org>; Sat, 18 May 2013 15:36:06 -0400 (EDT)
Date: Sat, 18 May 2013 21:33:56 +0200
From: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Subject: Re: [PATCH v7, part3 16/16] AVR32: fix building warnings caused by
 redifinitions of HZ
Message-ID: <20130518193356.GA4953@samfundet.no>
References: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
 <1368805518-2634-17-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368805518-2634-17-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

Around Fri 17 May 2013 23:45:18 +0800 or thereabout, Jiang Liu wrote:
> As suggested by David Howells <dhowells@redhat.com>, use
> asm-generic/param.h and uapi/asm-generic/param.h for AVR32.
> 
> It also fixes building warnings caused by redifinitions of HZ:
> In file included from /ws/linux/kernel/linux.git/include/uapi/linux/param.h:4,
>                  from include/linux/timex.h:63,
>                  from include/linux/jiffies.h:8,
>                  from include/linux/ktime.h:25,
>                  from include/linux/timer.h:5,
>                  from include/linux/workqueue.h:8,
>                  from include/linux/srcu.h:34,
>                  from include/linux/notifier.h:15,
>                  from include/linux/memory_hotplug.h:6,
>                  from include/linux/mmzone.h:777,
>                  from include/linux/gfp.h:4,
>                  from arch/avr32/mm/init.c:10:
> /ws/linux/kernel/linux.git/arch/avr32/include/asm/param.h:6:1: warning: "HZ" redefined
> In file included from /ws/linux/kernel/linux.git/arch/avr32/include/asm/param.h:4,
>                  from /ws/linux/kernel/linux.git/include/uapi/linux/param.h:4,
>                  from include/linux/timex.h:63,
>                  from include/linux/jiffies.h:8,
>                  from include/linux/ktime.h:25,
>                  from include/linux/timer.h:5,
>                  from include/linux/workqueue.h:8,
>                  from include/linux/srcu.h:34,
>                  from include/linux/notifier.h:15,
>                  from include/linux/memory_hotplug.h:6,
>                  from include/linux/mmzone.h:777,
>                  from include/linux/gfp.h:4,
>                  from arch/avr32/mm/init.c:10:
> /ws/linux/kernel/linux.git/arch/avr32/include/uapi/asm/param.h:6:1: warning: this is the location of the previous definition
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: linux-kernel@vger.kernel.org

Thanks, I'll pull this into the linux-avr32 tree. I'm in the mountains right
now, but will make a pull request early next week.

Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

> ---
>  arch/avr32/include/asm/Kbuild       |  1 +
>  arch/avr32/include/asm/param.h      |  9 ---------
>  arch/avr32/include/uapi/asm/Kbuild  |  1 +
>  arch/avr32/include/uapi/asm/param.h | 18 ------------------
>  4 files changed, 2 insertions(+), 27 deletions(-)
>  delete mode 100644 arch/avr32/include/asm/param.h
>  delete mode 100644 arch/avr32/include/uapi/asm/param.h

<snipp diff>

-- 
HcE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
