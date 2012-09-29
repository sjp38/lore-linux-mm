Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 1650E6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 22:32:08 -0400 (EDT)
Received: by obcva7 with SMTP id va7so4436968obc.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 19:32:07 -0700 (PDT)
Message-ID: <50665D94.7040802@gmail.com>
Date: Sat, 29 Sep 2012 10:31:48 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] bugfix for memory hotplug
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

On 09/27/2012 01:45 PM, wency@cn.fujitsu.com wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> Wen Congyang (2):
>    memory-hotplug: clear hwpoisoned flag when onlining pages
>    memory-hotplug: auto offline page_cgroup when onlining memory block
>      failed

Again, you should explain these two patches are the new version of 
memory-hotplug: hot-remove physical memory [20/21,21/21]

>
> Yasuaki Ishimatsu (2):
>    memory-hotplug: add memory_block_release
>    memory-hotplug: add node_device_release
>
>   drivers/base/memory.c |    9 ++++++++-
>   drivers/base/node.c   |   11 +++++++++++
>   mm/memory_hotplug.c   |    8 ++++++++
>   mm/page_cgroup.c      |    3 +++
>   4 files changed, 30 insertions(+), 1 deletions(-)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
