Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2F46B02A6
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 09:30:03 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so75130582pac.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 06:30:02 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id fd1si9029656pad.44.2015.10.01.06.30.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Oct 2015 06:30:01 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 1 Oct 2015 18:59:58 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 57E96E005A
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 18:59:43 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t91DTeMa9896208
	for <linux-mm@kvack.org>; Thu, 1 Oct 2015 18:59:40 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t91DTdAp014268
	for <linux-mm@kvack.org>; Thu, 1 Oct 2015 18:59:39 +0530
Message-ID: <560D3542.6060903@linux.vnet.ibm.com>
Date: Thu, 01 Oct 2015 18:59:38 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
In-Reply-To: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>, akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, mhocko@suse.cz, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

On 10/01/2015 04:18 PM, Pintu Kumar wrote:
> This patch maintains number of oom calls and number of oom kill
> count in /proc/vmstat.
> It is helpful during sluggish, aging or long duration tests.
> Currently if the OOM happens, it can be only seen in kernel ring buffer.
> But during long duration tests, all the dmesg and /var/log/messages* could
> be overwritten.
> So, just like other counters, the oom can also be maintained in
> /proc/vmstat.
> It can be also seen if all logs are disabled in kernel.

Makes sense.

> 
> A snapshot of the result of over night test is shown below:
> $ cat /proc/vmstat
> oom_stall 610
> oom_kill_count 1763
> 
> Here, oom_stall indicates that there are 610 times, kernel entered into OOM
> cases. However, there were around 1763 oom killing happens.
> The OOM is bad for the any system. So, this counter can help the developer
> in tuning the memory requirement at least during initial bringup.

Can you please fix the formatting of the commit message above ?

> 
> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> ---
>  include/linux/vm_event_item.h |    2 ++
>  mm/oom_kill.c                 |    2 ++
>  mm/page_alloc.c               |    2 +-
>  mm/vmstat.c                   |    2 ++
>  4 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 2b1cef8..ade0851 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -57,6 +57,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  #ifdef CONFIG_HUGETLB_PAGE
>  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
>  #endif
> +		OOM_STALL,
> +		OOM_KILL_COUNT,

Removing the COUNT will be better and in sync with others.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
