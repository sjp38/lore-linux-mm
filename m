Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E452440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 02:44:50 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b189so3358493wmd.9
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 23:44:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor3812080edf.47.2017.11.08.23.44.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 23:44:49 -0800 (PST)
Subject: Re: [PATCH] userfaultfd.2: document spurious UFFD_EVENT_FORK
References: <1510124048-7991-1-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <1b812837-b368-5e6e-ff9d-7d570354437a@gmail.com>
Date: Thu, 9 Nov 2017 08:44:47 +0100
MIME-Version: 1.0
In-Reply-To: <1510124048-7991-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-man@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 11/08/2017 07:54 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks, Mike. Applied.

Cheers,

Michael


> ---
>  man2/userfaultfd.2 | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index 1c9e64b..08c41e1 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -465,6 +465,16 @@ for checkpoint/restore mechanisms,
>  as well as post-copy migration to allow (nearly) uninterrupted execution
>  when transferring virtual machines and Linux containers
>  from one host to another.
> +.SH BUGS
> +If the
> +.B UFFD_FEATURE_EVENT_FORK
> +is enabled and a system call from the
> +.BR fork (2)
> +family is interrupted by a signal or failed,q a stale userfaultfd descriptor
> +might be created.
> +In this case a spurious
> +.B UFFD_EVENT_FORK
> +will be delivered to the userfaultfd monitor.
>  .SH EXAMPLE
>  The program below demonstrates the use of the userfaultfd mechanism.
>  The program creates two threads, one of which acts as the
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
