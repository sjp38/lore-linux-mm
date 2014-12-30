Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8FA6B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 15:48:56 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so26155394wiv.4
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 12:48:55 -0800 (PST)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id cu3si80943696wjb.20.2014.12.30.12.48.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 12:48:55 -0800 (PST)
Received: by mail-wg0-f50.google.com with SMTP id a1so21126858wgh.23
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 12:48:55 -0800 (PST)
Message-ID: <54A30FB4.8020606@gmail.com>
Date: Tue, 30 Dec 2014 21:48:52 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] posix_fadvise.2: Document the behaviour of partial
 page discard requests
References: <1417567367-9298-1-git-send-email-mgorman@suse.de> <1417567367-9298-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1417567367-9298-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: mtk.manpages@gmail.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/03/2014 01:42 AM, Mel Gorman wrote:
> It is not obvious from the interface that partial page discard requests
> are ignored. It should be spelled out.

Thanks, Mel. Applied.

Cheers,

Michael


> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  man2/posix_fadvise.2 | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/man2/posix_fadvise.2 b/man2/posix_fadvise.2
> index 25d0c50..07313a9 100644
> --- a/man2/posix_fadvise.2
> +++ b/man2/posix_fadvise.2
> @@ -144,6 +144,11 @@ A program may periodically request the kernel to free cached data
>  that has already been used, so that more useful cached pages are not
>  discarded instead.
>  
> +Requests to discard partial pages are ignored. It is preferable to preserve
> +needed data than discard unneeded data. If the application requires that
> +data be considered for discarding then \fIoffset\fP and \fIlen\fP must be
> +page-aligned.
> +
>  Pages that have not yet been written out will be unaffected, so if the
>  application wishes to guarantee that pages will be released, it should
>  call
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
