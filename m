Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E8DB5440313
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 21:05:57 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so19018883pad.1
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 18:05:57 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ct3si35978764pad.103.2015.10.04.18.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Oct 2015 18:05:57 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so158363326pab.3
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 18:05:56 -0700 (PDT)
Date: Sun, 4 Oct 2015 18:05:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 1/4] mm, documentation: clarify /proc/pid/status VmSwap
 limitations
In-Reply-To: <1443792951-13944-2-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.LSU.2.11.1510041756330.15067@eggly.anvils>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz> <1443792951-13944-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri, 2 Oct 2015, Vlastimil Babka wrote:

> The documentation for /proc/pid/status does not mention that the value of
> VmSwap counts only swapped out anonymous private pages and not shmem. This is
> not obvious, so document this limitation.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  Documentation/filesystems/proc.txt | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index a99b208..7ef50cb 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -239,6 +239,8 @@ Table 1-2: Contents of the status files (as of 4.1)
>   VmPTE                       size of page table entries
>   VmPMD                       size of second level page tables
>   VmSwap                      size of swap usage (the number of referred swapents)
> +                             by anonymous private data (shmem swap usage is not
> +                             included)

I have difficulty in reading "size of swap usage (the number of referred
swapents) by anonymous private data (shmem swap usage is not included)".

Luckily, VmSwap never was "the number of referred swapents", it's in kB.
So I suggest                    amount of swap used by anonymous private data
                                (shmem swap usage is not included)

for which you can assume Acked-by: Hugh Dickins <hughd@google.com>

Hugh

>   HugetlbPages                size of hugetlb memory portions
>   Threads                     number of threads
>   SigQ                        number of signals queued/max. number for queue
> -- 
> 2.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
