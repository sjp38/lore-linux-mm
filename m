Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id EBF486B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 07:27:37 -0400 (EDT)
Received: by mail-bk0-f46.google.com with SMTP id v15so286464bkz.19
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 04:27:37 -0700 (PDT)
Received: from mail-bk0-x230.google.com (mail-bk0-x230.google.com [2a00:1450:4008:c01::230])
        by mx.google.com with ESMTPS id dg3si3222879bkc.299.2014.04.04.04.27.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 04:27:36 -0700 (PDT)
Received: by mail-bk0-f48.google.com with SMTP id mx12so274016bkb.7
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 04:27:35 -0700 (PDT)
Message-ID: <533E9725.90708@gmail.com>
Date: Fri, 04 Apr 2014 13:27:33 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] maps.2: fd for a file mapping must be opened for reading
References: <1396599875-10562-1-git-send-email-avagin@openvz.org>
In-Reply-To: <1396599875-10562-1-git-send-email-avagin@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/04/2014 10:24 AM, Andrey Vagin wrote:
> Here is no difference between MAP_SHARED and MAP_PRIVATE.

Thanks, Andrey. That man page text has been there for a very long time,
but but does not seem to correspond to the truth in any kernel version
going back even to Linux 1.0. Patch applied.

Cheers,

Michael


> do_mmap_pgoff()
> 	switch (flags & MAP_TYPE) {
> 	case MAP_SHARED:
> 	...
> 	/* fall through */
> 	case MAP_PRIVATE:
> 		if (!(file->f_mode & FMODE_READ))
> 			return -EACCES;
> 
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  man2/mmap.2 | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index c0fd321..b469f84 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -393,9 +393,7 @@ is set (probably to
>  .TP
>  .B EACCES
>  A file descriptor refers to a non-regular file.
> -Or
> -.B MAP_PRIVATE
> -was requested, but
> +Or a file mapping was requested, but
>  .I fd
>  is not open for reading.
>  Or
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
