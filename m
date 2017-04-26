Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 19FB76B02EE
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:52:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h65so8225280wmd.7
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:52:53 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id v107si24882823wrc.121.2017.04.25.23.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 23:52:51 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id u65so30581192wmu.3
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:52:51 -0700 (PDT)
Subject: Re: [PATCH 2/5] ioctl_userfaultfd.2: describe memory types that can
 be used from 4.11
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493137748-32452-3-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <d22cd916-d9fc-71f7-d451-e4cbd818874c@gmail.com>
Date: Wed, 26 Apr 2017 08:52:50 +0200
MIME-Version: 1.0
In-Reply-To: <1493137748-32452-3-git-send-email-rppt@linux.vnet.ibm.com>
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
>  man2/ioctl_userfaultfd.2 | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> index 66fbfdc..78abc4d 100644
> --- a/man2/ioctl_userfaultfd.2
> +++ b/man2/ioctl_userfaultfd.2
> @@ -169,11 +169,15 @@ field was not zero.
>  (Since Linux 4.3.)
>  Register a memory address range with the userfaultfd object.
>  The pages in the range must be "compatible".
> -In the current implementation,
> -.\" According to Mike Rapoport, this will change in Linux 4.11.
> +
> +Up to Linux kernel 4.11,
>  only private anonymous ranges are compatible for registering with
>  .BR UFFDIO_REGISTER .
>  
> +Since Linux 4.11,
> +hugetlbfs and shared memory ranges are also compatible with
> +.BR UFFDIO_REGISTER .
> +
>  The
>  .I argp
>  argument is a pointer to a
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
