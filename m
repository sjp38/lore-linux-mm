Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id F11556B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:09:21 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id a41so595992yho.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2013 08:09:20 -0700 (PDT)
Date: Thu, 25 Jul 2013 11:09:13 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 17/21] page_alloc, mem-hotplug: Improve movablecore to
 {en|dis}able using SRAT.
Message-ID: <20130725150913.GD26107@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-18-git-send-email-tangchen@cn.fujitsu.com>
 <20130723210435.GV21100@mtj.dyndns.org>
 <20130723211119.GW21100@mtj.dyndns.org>
 <51F0A074.403@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F0A074.403@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello, Tang.

On Thu, Jul 25, 2013 at 11:50:12AM +0800, Tang Chen wrote:
> movablecore boot option was used to specify the size of ZONE_MOVABLE. And
> this patch-set aims to arrange ZONE_MOVABLE with SRAT info. So my original
> thinking is to reuse movablecore.
> 
> Since you said above, I think we have two problems here:
> 1. Should not let users care about where the hotplug info comes from.
> 2. Should not distinguish movable node and memory hotplug, since for now,
>    to use memory hotplug is to use movable node.
> 
> So how about something like "movablenode", just like "quiet" boot option.
> If users specify "movablenode", then memblock will reserve hotpluggable
> memory, and create movable nodes if any. If users specify nothing, then
> the kernel acts as before.

Maybe I'm confused but memory hotplug isn't likely to work without
this, right?  If so, wouldn't it make more sense to have
"memory_hotplug" option rather than "movablecore=acpi" which in no way
indicates that it has something to do with memory hotplug?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
