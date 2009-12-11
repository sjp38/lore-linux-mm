Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 134A16B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 16:24:55 -0500 (EST)
Message-ID: <4B22B89A.3060009@redhat.com>
Date: Fri, 11 Dec 2009 16:24:42 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091210185626.26f9828a@cuia.bos.redhat.com> <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
In-Reply-To: <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 12/10/2009 09:03 PM, Minchan Kim wrote:
> On Fri, Dec 11, 2009 at 8:56 AM, Rik van Riel<riel@redhat.com>  wrote:
>> Under very heavy multi-process workloads, like AIM7, the VM can
>> get into trouble in a variety of ways.  The trouble start when
>> there are hundreds, or even thousands of processes active in the
>> page reclaim code.

> Otherwise looks good to me.
>
> Reviewed-by: Minchan Kim<minchan.kim@gmail.com>

OK, we found three issues with my patch :)

1) there is a typo in sysctl.c

2) there is another typo in Documentation/vm/sysctl.c

3) the code in vmscan.c has a bug, where tasks without
     __GFP_IO or __GFP_FS can end up waiting for tasks
     with __GFP_IO or __GFP_FS, leading to a deadlock

I will fix these issues and send out a new patch.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
