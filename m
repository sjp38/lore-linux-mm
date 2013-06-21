Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 243EF6B0034
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 02:03:52 -0400 (EDT)
Message-ID: <51C3ED76.3040900@cn.fujitsu.com>
Date: Fri, 21 Jun 2013 14:06:46 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com> <51C3E276.8030804@zytor.com>
In-Reply-To: <51C3E276.8030804@zytor.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Toshi Kani <toshi.kani@hp.com>

On 06/21/2013 01:19 PM, H. Peter Anvin wrote:
> On 06/13/2013 06:02 AM, Tang Chen wrote:
>> From: Yinghai Lu<yinghai@kernel.org>
>>
>> No offence, just rebase and resend the patches from Yinghai to help
>> to push this functionality faster.
>> Also improve the comments in the patches' log.
>>
>
> So we need a new version of this which addresses the build problems and
> the feedback from Tejun... and it would be good to get that soon, or
> we'll be looking at 3.12.

Hi hpa,

The build problem has been fixed by Yinghai.

>
> Since the merge window is approaching quickly, is there a meaningful
> subset that is ready now?

I think memory hotplug needs at least part1 and part2 patches. But
local node pagetable (patch 21 and 22 in part1) will break memory
hot-remove path. My part3 intends to fix it, but it seems we need
local device pagetable to enable single device hotplug, but not just
local node pagetable.

So, my plan is

1. Implement arranging hotpluggable memory with SRAT first, within tj's
    comments, without local node pagetable.
    (The main work in part2. And of course, need some patches in part1.)
2. Do the local device pagetable work, not local node.
3. Improve memory hotplug to support local device pagetable.

I'll send a new version patch-set of step1, wishing we can catch up with
the merge window. And I think step2 and 3 should be done later.


Thanks. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
