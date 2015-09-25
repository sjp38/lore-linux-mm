Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id EE93B6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 07:36:39 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so17903493wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:36:39 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id fq6si4059002wib.110.2015.09.25.04.36.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 04:36:38 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so17903085wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:36:38 -0700 (PDT)
Date: Fri, 25 Sep 2015 13:36:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/4] mm, documentation: clarify /proc/pid/status
 VmSwap limitations
Message-ID: <20150925113637.GH16497@dhcp22.suse.cz>
References: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
 <1438779685-5227-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438779685-5227-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Minchan Kim <minchan@kernel.org>

[Sorry for a really long delay]

On Wed 05-08-15 15:01:22, Vlastimil Babka wrote:
> The documentation for /proc/pid/status does not mention that the value of
> VmSwap counts only swapped out anonymous private pages and not shmem. This is
> not obvious, so document this limitation.

This is definitely an improvement
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  Documentation/filesystems/proc.txt | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index d411ca6..29f4011 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -237,6 +237,8 @@ Table 1-2: Contents of the status files (as of 4.1)
>   VmPTE                       size of page table entries
>   VmPMD                       size of second level page tables
>   VmSwap                      size of swap usage (the number of referred swapents)
> +                             by anonymous private data (shmem swap usage is not
> +                             included)
>   Threads                     number of threads
>   SigQ                        number of signals queued/max. number for queue
>   SigPnd                      bitmap of pending signals for the thread
> -- 
> 2.4.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
