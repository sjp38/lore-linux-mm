Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id D591E6B00CD
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 05:42:59 -0400 (EDT)
Received: by obcva7 with SMTP id va7so7420224obc.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 02:42:59 -0700 (PDT)
Message-ID: <506AB719.70904@gmail.com>
Date: Tue, 02 Oct 2012 17:42:49 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] memory-hotplug : notification of memoty block's state
References: <506AA4E2.7070302@jp.fujitsu.com>
In-Reply-To: <506AA4E2.7070302@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On 10/02/2012 04:25 PM, Yasuaki Ishimatsu wrote:
> We are trying to implement a physical memory hot removing function as
> following thread.
>
> https://lkml.org/lkml/2012/9/5/201
>
> But there is not enough review to merge into linux kernel.
>
> I think there are following blockades.
>   1. no physical memory hot removable system
>   2. huge patch-set
>
> If you have a KVM system, we can get rid of 1st blockade. Because
> applying following patch, we can create memory hot removable system
> on KVM guest.
>
> http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html
>
> 2nd blockade is own problem. So we try to divide huge patch into
> a small patch in each function as follows: 
>
>  - bug fix
>  - acpi framework
>  - kernel core
>
> We had already sent bug fix patches.
>
> https://lkml.org/lkml/2012/9/27/39
>
> And the patch fixes following bug.
>
> remove_memory() offlines memory. And it is called by following two cases:
>
> 1. echo offline >/sys/devices/system/memory/memoryXX/state
> 2. hot remove a memory device
>
> In the 1st case, the memory block's state is changed and the notification
> that memory block's state changed is sent to userland after calling
> offline_memory(). So user can notice memory block is changed.,

Hi Yasuaki,

Thanks for splitting the patchset, it's more easier to review this time.
One question:

How can notify userspace? you mean function node_memory_callback or
...., but
this function basically do nothing.

>
> But in the 2nd case, the memory block's state is not changed and the
> notification is not also sent to userspcae even if calling offline_memory().
> So user cannot notice memory block is changed.
>
> We should also notify to userspace at 2nd case.
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
