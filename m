Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 610B18D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 09:36:21 -0500 (EST)
Message-ID: <4D3999BC.7000107@redhat.com>
Date: Fri, 21 Jan 2011 09:35:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: System without MMU do not need pte_mkwrite
References: <1295596196-8233-1-git-send-email-monstr@monstr.eu> <1295596196-8233-2-git-send-email-monstr@monstr.eu>
In-Reply-To: <1295596196-8233-2-git-send-email-monstr@monstr.eu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Simek <monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On 01/21/2011 02:49 AM, Michal Simek wrote:
> The patch "thp: export maybe_mkwrite"
> (sha1 14fd403f2146f740942d78af4e0ee59396ad8eab)
> break systems without MMU.
>
> Error log:
>    CC      arch/microblaze/mm/init.o
> In file included from include/linux/mman.h:14,
>                   from arch/microblaze/mm/consistent.c:24:
> include/linux/mm.h: In function 'maybe_mkwrite':
> include/linux/mm.h:482: error: implicit declaration of function 'pte_mkwrite'
> include/linux/mm.h:482: error: incompatible types in assignment
>
> Signed-off-by: Michal Simek<monstr@monstr.eu>
> CC: Andrea Arcangeli<aarcange@redhat.com>
> CC: Linus Torvalds<torvalds@linux-foundation.org>
> CC: Andrew Morton<akpm@linux-foundation.org>
> CC: Rik van Riel<riel@redhat.com>
> CC: Ingo Molnar<mingo@elte.hu>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
