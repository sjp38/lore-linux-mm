Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDE46B02F4
	for <linux-mm@kvack.org>; Mon,  1 May 2017 14:33:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d79so7414720wma.0
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:59 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id p32si16856646wrb.39.2017.05.01.11.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 11:33:58 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id z129so24837966wmb.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:58 -0700 (PDT)
Subject: Re: [PATCH man-pages 5/5] userfaultfd.2: update VERSIONS section with
 4.11 chanegs
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-6-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <6ef50ec3-facc-104c-6787-567ece15e817@gmail.com>
Date: Mon, 1 May 2017 20:33:56 +0200
MIME-Version: 1.0
In-Reply-To: <1493617399-20897-6-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Hi Mike,

On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks. Applied.

Cheers,

Michael


> ---
>  man2/userfaultfd.2 | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index f177bba..07a69f1 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -404,6 +404,9 @@ Insufficient kernel memory was available.
>  The
>  .BR userfaultfd ()
>  system call first appeared in Linux 4.3.
> +
> +The support for hugetlbfs and shared memory areas and
> +non-page-fault events was added in Linux 4.11
>  .SH CONFORMING TO
>  .BR userfaultfd ()
>  is Linux-specific and should not be used in programs intended to be
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
