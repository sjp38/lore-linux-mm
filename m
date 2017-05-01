Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2644A6B02F3
	for <linux-mm@kvack.org>; Mon,  1 May 2017 14:33:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t189so7389260wme.15
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:54 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id 131si4731520wmt.23.2017.05.01.11.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 11:33:53 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id y10so24806502wmh.0
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:52 -0700 (PDT)
Subject: Re: [PATCH man-pages 3/5] ioctl_userfaultfd.2: add BUGS section
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-4-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <345c064d-83fe-3e40-c5cb-5d4b6e5cdff4@gmail.com>
Date: Mon, 1 May 2017 20:33:50 +0200
MIME-Version: 1.0
In-Reply-To: <1493617399-20897-4-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Hi Mike,

I've applied this, but have a question.

On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> The features handshake is not quite convenient.
> Elaborate about it in the BUGS section.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  man2/ioctl_userfaultfd.2 | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> index e12b9de..50316de 100644
> --- a/man2/ioctl_userfaultfd.2
> +++ b/man2/ioctl_userfaultfd.2
> @@ -650,6 +650,15 @@ operations are Linux-specific.
>  .SH EXAMPLE
>  See
>  .BR userfaultfd (2).
> +.SH BUGS
> +In order to detect available userfault features and
> +enable certain subset of those features

I changed "certain" to "some". ("certain subset" here also
would sound like "some particular subset" of those features.)
Okay?

> +the usefault file descriptor must be closed after the first
> +.BR UFFDIO_API
> +operation that queries features availability and re-opened before
> +the second
> +.BR UFFDIO_API
> +call that actually enables the desired features.
>  .SH SEE ALSO
>  .BR ioctl (2),
>  .BR mmap (2),

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
