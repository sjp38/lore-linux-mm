Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3AC6B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 10:19:27 -0500 (EST)
Received: by mail-lf0-f44.google.com with SMTP id y184so112840998lfc.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 07:19:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si18648779lbb.134.2015.12.21.07.19.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 07:19:25 -0800 (PST)
Subject: Re: [PATCH] Documentation: Describe the shared memory
 usage/accounting
References: <1281769343.11551980.1447959500824.JavaMail.zimbra@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5678187A.5070307@suse.cz>
Date: Mon, 21 Dec 2015 16:19:22 +0100
MIME-Version: 1.0
In-Reply-To: <1281769343.11551980.1447959500824.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rodrigo Freire <rfreire@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

On 11/19/2015 07:58 PM, Rodrigo Freire wrote:
>
> The Shared Memory accounting support is present in Kernel since
> commit 4b02108ac1b3 ("mm: oom analysis: add shmem vmstat") and in userland
> free(1) since 2014. This patch updates the Documentation to reflect
> this change.
>
> Signed-off-by: Rodrigo Freire <rfreire@redhat.com>

You should send to Andrew Morton and maybe CC Hugh Dickins at the very 
least. Sending just to mailing list doesn't guarantee maintainers will 
pick it up due to the high volume there.
Also note that your RESEND has broken whitespace.


> ---
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -842,6 +842,7 @@
>   Writeback:           0 kB
>   AnonPages:      861800 kB
>   Mapped:         280372 kB
> +Shmem:             644 kB
>   Slab:           284364 kB
>   SReclaimable:   159856 kB
>   SUnreclaim:     124508 kB
> @@ -898,6 +899,7 @@
>      AnonPages: Non-file backed pages mapped into userspace page tables
>   AnonHugePages: Non-file backed huge pages mapped into userspace page tables
>         Mapped: files which have been mmaped, such as libraries
> +       Shmem: Total memory used by shared memory (shmem) and tmpfs
>           Slab: in-kernel data structures cache
>   SReclaimable: Part of Slab, that might be reclaimed, such as caches
>     SUnreclaim: Part of Slab, that cannot be reclaimed on memory pressure
> --- a/Documentation/filesystems/tmpfs.txt
> +++ b/Documentation/filesystems/tmpfs.txt
> @@ -17,10 +17,10 @@
>   cannot swap and you do not have the possibility to resize them.
>
>   Since tmpfs lives completely in the page cache and on swap, all tmpfs
> -pages currently in memory will show up as cached. It will not show up
> -as shared or something like that. Further on you can check the actual
> -RAM+swap use of a tmpfs instance with df(1) and du(1).
> -
> +pages will be shown in /proc/meminfo as "Shmem" and "Shared" in

It would be IMHO clearer if it said:
... will be shown as "Shmem" in /proc/meminfo and "Shared" in ...

> +free(1). Notice that shared memory pages (see ipcs(1)) will be also
 > +counted as shared memory.

Too much of "shared memory" here. Maybe something like:
"However, these counters also include shared memory (shmem)."

> The most reliable way to get the count is
> +using df(1) and du(1).
>
>   tmpfs has the following uses:
>
> ---
> 1.7.1
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
