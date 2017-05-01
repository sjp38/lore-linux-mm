Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E391F6B02EE
	for <linux-mm@kvack.org>; Mon,  1 May 2017 14:33:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z88so11887107wrc.9
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:39 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id t15si17056833wrb.108.2017.05.01.11.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 11:33:38 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id d79so24869226wmi.2
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:38 -0700 (PDT)
Subject: Re: [PATCH man-pages 2/5] ioctl_userfaultfd.2: UFFDIO_COPY: add
 ENOENT and ENOSPC description
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-3-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <d621f4e3-01bb-5213-be64-8253d84bddb5@gmail.com>
Date: Mon, 1 May 2017 20:33:36 +0200
MIME-Version: 1.0
In-Reply-To: <1493617399-20897-3-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks, Mike. Applied.

Cheers,

Michael


> ---
>  man2/ioctl_userfaultfd.2 | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> index 6edd396..e12b9de 100644
> --- a/man2/ioctl_userfaultfd.2
> +++ b/man2/ioctl_userfaultfd.2
> @@ -481,6 +481,19 @@ was invalid.
>  An invalid bit was specified in the
>  .IR mode
>  field.
> +.TP
> +.B ENOENT
> +(Since Linux 4.11)
> +The faulting process has changed
> +its virtual memory layout simultaneously with outstanding
> +.I UFFDIO_COPY
> +operation.
> +.TP
> +.B ENOSPC
> +(Since Linux 4.11)
> +The faulting process has exited at the time of
> +.I UFFDIO_COPY
> +operation.
>  .\"
>  .SS UFFDIO_ZEROPAGE
>  (Since Linux 4.3.)
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
