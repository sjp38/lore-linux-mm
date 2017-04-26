Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A07846B0311
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 03:18:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p138so5728565wmg.3
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 00:18:17 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id w105si13267125wrc.147.2017.04.26.00.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 00:18:16 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id z129so30786949wmb.1
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 00:18:16 -0700 (PDT)
Subject: Re: [PATCH 5/5] usefaultfd.2: add brief description of
 "non-cooperative" mode
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493137748-32452-6-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <a1600fd7-a391-dd6e-8f35-c73df9f29923@gmail.com>
Date: Wed, 26 Apr 2017 09:18:14 +0200
MIME-Version: 1.0
In-Reply-To: <1493137748-32452-6-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On 04/25/2017 06:29 PM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks, Mike. Applied.

Cheers,

Michael

> ---
>  man2/userfaultfd.2 | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index dc37319..291dd10 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -89,6 +89,20 @@ them using the operations described in
>  .BR ioctl_userfaultfd (2).
>  When servicing the page fault events,
>  the fault-handling thread can trigger a wake-up for the sleeping thread.
> +
> +It is possible for the faulting threads and the fault-handling threads
> +to run in the context of different processes.
> +In this case, these threads may belong to different programs,
> +and the program that executes the faulting threads
> +will not necessarily cooperate with the program that handles the page faults.
> +In such non-cooperative mode,
> +the process that monitors userfaultfd and handles page faults,
> +needs to be aware of the changes in the virtual memory layout
> +of the faulting process to avoid memory corruption.
> +.\" FIXME elaborate about non-cooperating mode, describe its limitations
> +.\" for kerneles before 4.11, features added in 4.11
> +.\" and limitations remaining in 4.11
> +.\" Maybe it's worth adding a dedicated sub-section...
>  .\"
>  .SS Userfaultfd operation
>  After the userfaultfd object is created with
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
