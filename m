Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 780106B0062
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 04:23:54 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id m15so5265723lah.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 01:23:52 -0800 (PST)
Message-ID: <50ADEF2B.4030106@googlemail.com>
Date: Thu, 22 Nov 2012 09:23:55 +0000
From: Chris Clayton <chris2553@googlemail.com>
MIME-Version: 1.0
Subject: Re: [RFT PATCH v1 0/5] fix up inaccurate zone->present_pages
References: <20121115112454.e582a033.akpm@linux-foundation.org> <1353254850-27336-1-git-send-email-jiang.liu@huawei.com> <50A946BC.7010308@googlemail.com>
In-Reply-To: <50A946BC.7010308@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Clayton <chris2553@googlemail.com>
Cc: Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>> This patchset has only been tested on x86_64 with nobootmem.c. So need
>> help to test this patchset on machines:
>> 1) use bootmem.c
>> 2) have highmem
>>
>> This patchset applies to "f4a75d2e Linux 3.7-rc6" from
>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
>>
>
> I've applied the five patches to Linus' 3.7.0-rc6 and can confirm that
> the kernel allows my system to resume from a suspend to disc. Although
> my laptop is 64 bit, I run a 32 bit kernel with HIGHMEM (I have 8GB RAM):
>
> [chris:~/kernel/tmp/linux-3.7-rc6-resume]$ grep -E HIGHMEM\|X86_32 .config
> CONFIG_X86_32=y
> CONFIG_X86_32_SMP=y
> CONFIG_X86_32_LAZY_GS=y
> # CONFIG_X86_32_IRIS is not set
> # CONFIG_NOHIGHMEM is not set
> # CONFIG_HIGHMEM4G is not set
> CONFIG_HIGHMEM64G=y
> CONFIG_HIGHMEM=y
>
> I can also say that a quick browse of the output of dmesg, shows nothing
> out of the ordinary. I have insufficient knowledge to comment on the
> patches, but I will run the kernel over the next few days and report
> back later in the week.
>

Well, I've been running the kernel since Sunday and have had no problems 
with my normal work mix of browsing, browsing the internet, video 
editing, listening to music and building software. I'm now running a 
kernel that build with the new patches 1 and 4 from yesterday (plus the 
original 1, 2 and 5). All seems OK so far, including a couple of resumes 
from suspend to disk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
