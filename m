Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C86AD6B02F4
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 03:16:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u65so8251131wmu.12
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 00:16:18 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id b130si7128715wma.58.2017.04.26.00.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 00:16:17 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id w50so23513328wrc.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 00:16:17 -0700 (PDT)
Subject: Re: [PATCH 4/5] userfaultfd.2: add Linux container migration use-case
 to NOTES
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493137748-32452-5-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <2ca614a1-bd71-3bd0-83e7-7628b7221a6c@gmail.com>
Date: Wed, 26 Apr 2017 09:16:15 +0200
MIME-Version: 1.0
In-Reply-To: <1493137748-32452-5-git-send-email-rppt@linux.vnet.ibm.com>
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
>  man2/userfaultfd.2 | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index c89484f..dc37319 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -279,7 +279,8 @@ signal and
>  It can also be used to implement lazy restore
>  for checkpoint/restore mechanisms,
>  as well as post-copy migration to allow (nearly) uninterrupted execution
> -when transferring virtual machines from one host to another.
> +when transferring virtual machines and Linux containers
> +from one host to another.
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
