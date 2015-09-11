Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A50736B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 07:47:47 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so59702502wic.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 04:47:47 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id br2si1413590wjb.123.2015.09.11.04.47.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 04:47:46 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so61019130wic.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 04:47:45 -0700 (PDT)
Message-ID: <55F2BF5E.2000505@gmail.com>
Date: Fri, 11 Sep 2015 13:47:42 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap.2: Add note about mremap with locked areas
References: <1440787372-30214-1-git-send-email-emunson@akamai.com>
In-Reply-To: <1440787372-30214-1-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: mtk.manpages@gmail.com, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/28/2015 08:42 PM, Eric B Munson wrote:
> When mremap() is used to move or expand a mapping that is locked with
> mlock() or equivalent it will attempt to populate the new area.
> However, like mmap(MAP_LOCKED), mremap() will not fail if the area
> cannot be populated.  Also like mmap(MAP_LOCKED) this might come as a
> surprise to users and should be noted.

Thanks, Eric! 

Applied, with Michael's Acked-by added.

Cheers,

Michael


> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Cc: linux-man@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  man2/mremap.2 | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/man2/mremap.2 b/man2/mremap.2
> index 071adb5..cf884e6 100644
> --- a/man2/mremap.2
> +++ b/man2/mremap.2
> @@ -196,6 +196,17 @@ and the prototype for
>  did not allow for the
>  .I new_address
>  argument.
> +
> +If
> +.BR mremap ()
> +is used to move or expand an area locked with
> +.BR mlock (2)
> +or equivalent, the
> +.BR mremap ()
> +call will make a best effort to populate the new area but will not fail
> +with
> +.B ENOMEM
> +if the area cannot be populated.
>  .SH SEE ALSO
>  .BR brk (2),
>  .BR getpagesize (2),
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
