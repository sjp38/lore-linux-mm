Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5D56B02F2
	for <linux-mm@kvack.org>; Mon,  1 May 2017 14:33:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n198so7416889wmg.9
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:48 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id y95si10339166wmh.97.2017.05.01.11.33.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 11:33:46 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id z129so24837113wmb.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:33:46 -0700 (PDT)
Subject: Re: [PATCH man-pages 4/5] userfaultfd.2: add note about asynchronios
 events delivery
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-5-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <5fb9e169-5d92-2fe8-cc59-5c68cfb6be72@gmail.com>
Date: Mon, 1 May 2017 20:33:45 +0200
MIME-Version: 1.0
In-Reply-To: <1493617399-20897-5-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Hi Mike,

On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks. Applied. One question below.

> ---
>  man2/userfaultfd.2 | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index 8b89162..f177bba 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -112,6 +112,18 @@ created for the child process,
>  which allows userfaultfd monitor to perform user-space paging
>  for the child process.
>  
> +Unlike page faults which have to be synchronous and require
> +explicit or implicit wakeup,
> +all other events are delivered asynchronously and
> +the non-cooperative process resumes execution as
> +soon as manager executes
> +.BR read(2).
> +The userfaultfd manager should carefully synchronize calls
> +to UFFDIO_COPY with the events processing.
> +
> +The current asynchronous model of the event delivery is optimal for
> +single threaded non-cooperative userfaultfd manager implementations.

The preceding paragraph feels incomplete. It seems like you want to make
a point with that last sentence, but the point is not explicit. What's
missing?

> +
>  .\" FIXME elaborate about non-cooperating mode, describe its limitations
>  .\" for kernels before 4.11, features added in 4.11
>  .\" and limitations remaining in 4.11
> 

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
