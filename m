Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 13DD26B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 05:14:07 -0400 (EDT)
Received: by widfa3 with SMTP id fa3so17629704wid.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 02:14:06 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id x8si19949795wiy.50.2015.08.31.02.14.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 02:14:05 -0700 (PDT)
Received: by wicfv10 with SMTP id fv10so56933445wic.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 02:14:05 -0700 (PDT)
Date: Mon, 31 Aug 2015 11:14:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mremap.2: Add note about mremap with locked areas
Message-ID: <20150831091403.GD29723@dhcp22.suse.cz>
References: <1440787372-30214-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440787372-30214-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: mtk.manpages@gmail.com, David Rientjes <rientjes@google.com>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 28-08-15 14:42:52, Eric B Munson wrote:
> When mremap() is used to move or expand a mapping that is locked with
> mlock() or equivalent it will attempt to populate the new area.
> However, like mmap(MAP_LOCKED), mremap() will not fail if the area
> cannot be populated.  Also like mmap(MAP_LOCKED) this might come as a
> surprise to users and should be noted.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

Thank you for following on this.

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
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
