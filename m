Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9094C6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 14:33:38 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b6so11839794wra.16
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:38 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id c80si9946160wmh.59.2017.05.01.11.33.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 11:33:37 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id v42so14494239wrc.3
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:36 -0700 (PDT)
Subject: Re: [PATCH man-pages 1/5] ioctl_userfaultfd.2: update description of
 shared memory areas
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-2-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <7ec5dfc0-9d84-e142-bfaa-d96383acbee9@gmail.com>
Date: Mon, 1 May 2017 20:33:31 +0200
MIME-Version: 1.0
In-Reply-To: <1493617399-20897-2-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Hello Mike,

I've applied this patch, but  have a question.

On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  man2/ioctl_userfaultfd.2 | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> index 889feb9..6edd396 100644
> --- a/man2/ioctl_userfaultfd.2
> +++ b/man2/ioctl_userfaultfd.2
> @@ -181,8 +181,17 @@ virtual memory areas
>  .TP
>  .B UFFD_FEATURE_MISSING_SHMEM
>  If this feature bit is set,
> -the kernel supports registering userfaultfd ranges on tmpfs
> -virtual memory areas
> +the kernel supports registering userfaultfd ranges on shared memory areas.
> +This includes all kernel shared memory APIs:
> +System V shared memory,
> +tmpfs,
> +/dev/zero,
> +.BR mmap(2)
> +with
> +.I MAP_SHARED
> +flag set,
> +.BR memfd_create (2),
> +etc.
>  
>  The returned
>  .I ioctls

Does the change in this patch represent a change that occurred in
Linux 4.11? If so, I think this needs to be said explicitly in the text.

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
