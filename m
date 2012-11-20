Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 7749C6B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 22:49:12 -0500 (EST)
Message-ID: <50AAFD0D.2010003@huawei.com>
Date: Tue, 20 Nov 2012 11:46:21 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFT PATCH v1 0/5] fix up inaccurate zone->present_pages
References: <20121115112454.e582a033.akpm@linux-foundation.org> <1353254850-27336-1-git-send-email-jiang.liu@huawei.com> <50AAE72E.3090101@gmail.com> <50AAEE61.2090504@huawei.com> <50AAF6F3.8010203@gmail.com>
In-Reply-To: <50AAF6F3.8010203@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2012-11-20 11:20, Jaegeuk Hanse wrote:
> On 11/20/2012 10:43 AM, Jiang Liu wrote:
>> On 2012-11-20 10:13, Jaegeuk Hanse wrote:
>>> On 11/19/2012 12:07 AM, Jiang Liu wrote:
>> Hi Jaegeuk,
>>     Thanks for review this patch set.
>>     Currently x86/x86_64/Sparc have been converted to use nobootmem.c,
>> and other Arches still use bootmem.c. So need to test it on other Arches,
>> such as ARM etc. Yesterday we have tested it patchset on an Itanium platform,
>> so bootmem.c should work as expected too.
> 
> Hi Jiang,
> 
> If there are any codes changed in x86/x86_64  to meet nobootmem.c logic? I mean if remove
> config NO_BOOTMEM
>        def_bool y
> in arch/x86/Kconfig, whether x86/x86_64 can take advantage of bootmem.c or not.
There are code change in x86/x86_64 arch directory to convert from bootmem.c
to nobootmem.c, so you can't simply comment out NO_BOOTMEM Kconfig item.
There are differences in APIs for bootmem.c and nobootmem.c.
For example, free_low_memory_core_early() is only provided by nobootmem.c
and init_bootmem_node() is only provided by bootmem.c.
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
