Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E820B6B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 17:05:25 -0400 (EDT)
Message-ID: <51C36E91.2020509@mozilla.com>
Date: Thu, 20 Jun 2013 17:05:21 -0400
From: Dhaval Giani <dgiani@mozilla.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] vrange: Add new vrange(2) system call
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org> <1371010971-15647-6-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1371010971-15647-6-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2013-06-12 12:22 AM, John Stultz wrote:
> From: Minchan Kim <minchan@kernel.org>
>
> This patch adds new system call sys_vrange.
>
> NAME
> 	vrange - Mark or unmark range of memory as volatile
>
> SYNOPSIS
> 	int vrange(unsigned_long start, size_t length, int mode,
> 			 int *purged);
>
> DESCRIPTION
> 	Applications can use vrange(2) to advise the kernel how it should
> 	handle paging I/O in this VM area.  The idea is to help the kernel
> 	discard pages of vrange instead of reclaiming when memory pressure
> 	happens. It means kernel doesn't discard any pages of vrange if
> 	there is no memory pressure.
>
> 	mode:
> 	VRANGE_VOLATILE
> 		hint to kernel so VM can discard in vrange pages when
> 		memory pressure happens.
> 	VRANGE_NONVOLATILE
> 		hint to kernel so VM doesn't discard vrange pages
> 		any more.
>
> 	If user try to access purged memory without VRANGE_NOVOLATILE call,
> 	he can encounter SIGBUS if the page was discarded by kernel.

I wonder if it would be possible to provide additional information here, 
for example "purge range at a time" as opposed to "purge page at a 
time". There are some valid use cases for both approaches and it doesn't 
make sense to deny one use case.

Thanks!
Dhaval

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
