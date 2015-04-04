Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB436B0038
	for <linux-mm@kvack.org>; Sat,  4 Apr 2015 03:50:14 -0400 (EDT)
Received: by wiun10 with SMTP id n10so13428672wiu.1
        for <linux-mm@kvack.org>; Sat, 04 Apr 2015 00:50:13 -0700 (PDT)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id kq8si18286448wjb.112.2015.04.04.00.50.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Apr 2015 00:50:12 -0700 (PDT)
Received: by wgdm6 with SMTP id m6so125894930wgd.2
        for <linux-mm@kvack.org>; Sat, 04 Apr 2015 00:50:11 -0700 (PDT)
Message-ID: <551F90EC.20600@gmail.com>
Date: Sat, 04 Apr 2015 08:21:16 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch] madvise.2: specify MADV_REMOVE returns EINVAL for hugetlbfs
References: <alpine.DEB.2.10.1504021517540.9951@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1504021517540.9951@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: mtk.manpages@gmail.com, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On 04/02/2015 11:21 PM, David Rientjes wrote:
> madvise(2) actually returns with error EINVAL for MADV_REMOVE when used 
> for hugetlb vmas, not EOPNOTSUPP, and this has been the case since 
> MADV_REMOVE was introduced in commit f6b3ec238d12 ("madvise(MADV_REMOVE): 
> remove pages from tmpfs shm backing store").

Thanks David. Applied. I'd already fixed the appropriate piece in
the ERRORS list a while back, but missed that piece in the main text.

Cheers,

Michael


> Specify the exact behavior.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  man2/madvise.2 | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/man2/madvise.2 b/man2/madvise.2
> index a3d93bb..00db39d 100644
> --- a/man2/madvise.2
> +++ b/man2/madvise.2
> @@ -184,7 +184,9 @@ any filesystem which supports the
>  .BR FALLOC_FL_PUNCH_HOLE
>  mode also supports
>  .BR MADV_REMOVE .
> -Other filesystems fail with the error
> +Hugetlbfs will fail with the error
> +.BR EINVAL
> +and other filesystems fail with the error
>  .BR EOPNOTSUPP .
>  .TP
>  .BR MADV_DONTFORK " (since Linux 2.6.16)"
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
