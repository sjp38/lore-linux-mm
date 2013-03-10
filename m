Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id C12C96B0005
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 06:40:51 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id x51so2507494wey.32
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 03:40:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLHoWGo+B9w-Vmxdv_YWneEqN0U_2cSuvM7H4U67sfFksg@mail.gmail.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
	<1362902470-25787-11-git-send-email-jiang.liu@huawei.com>
	<CAOJsxLHoWGo+B9w-Vmxdv_YWneEqN0U_2cSuvM7H4U67sfFksg@mail.gmail.com>
Date: Sun, 10 Mar 2013 12:40:49 +0200
Message-ID: <CAOJsxLGmsLdVxab6HMNXbfbCARna+9e0e4q=PS9nQC+bMXokeg@mail.gmail.com>
Subject: Re: [PATCH v2, part2 10/10] mm/x86: use free_highmem_page() to free
 highmem pages into buddy system
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Cong Wang <amwang@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Attilio Rao <attilio.rao@citrix.com>, konrad.wilk@oracle.com

On Sun, Mar 10, 2013 at 12:32 PM, Pekka Enberg <penberg@kernel.org> wrote:
> On Sun, Mar 10, 2013 at 10:01 AM, Jiang Liu <liuj97@gmail.com> wrote:
>> Use helper function free_highmem_page() to free highmem pages into
>> the buddy system.
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> ---
>>  arch/x86/mm/highmem_32.c |    1 -
>>  arch/x86/mm/init_32.c    |   10 +---------
>>  2 files changed, 1 insertion(+), 10 deletions(-)
>>
>> diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
>> index 6f31ee5..252b8f5 100644
>> --- a/arch/x86/mm/highmem_32.c
>> +++ b/arch/x86/mm/highmem_32.c
>> @@ -137,5 +137,4 @@ void __init set_highmem_pages_init(void)
>>                 add_highpages_with_active_regions(nid, zone_start_pfn,
>>                                  zone_end_pfn);
>>         }
>> -       totalram_pages += totalhigh_pages;
>
> Hmm? I haven't looked at what totalram_pages is used for but could you
> explain why this change is safe?

Never mind, I should have read the patchset more carefully:

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
