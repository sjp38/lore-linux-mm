Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 532E66B0038
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:52:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b20so8235411wma.11
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:52:25 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id c78si5663502wme.30.2017.04.25.23.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 23:52:19 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id g12so9743482wrg.2
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:52:19 -0700 (PDT)
Subject: Re: [PATCH 1/5] userfaultfd.2: describe memory types that can be used
 from 4.11
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493137748-32452-2-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <adc6c2a6-1cd8-cdf9-86b2-5e9e517833c8@gmail.com>
Date: Wed, 26 Apr 2017 08:52:16 +0200
MIME-Version: 1.0
In-Reply-To: <1493137748-32452-2-git-send-email-rppt@linux.vnet.ibm.com>
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
>  man2/userfaultfd.2 | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index 1603c20..c89484f 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -130,8 +130,12 @@ Details of the various
>  operations can be found in
>  .BR ioctl_userfaultfd (2).
>  
> -Currently, userfaultfd can be used only with anonymous private memory
> -mappings.
> +Up to Linux 4.11,
> +userfaultfd can be used only with anonymous private memory mappings.
> +
> +Since Linux 4.11,
> +userfaultfd can be also used with hugetlbfs and shared memory mappings.
> +
>  .\"
>  .SS Reading from the userfaultfd structure
>  Each
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
