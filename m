Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B12416B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 05:31:09 -0400 (EDT)
Date: Thu, 2 Jun 2011 11:30:26 +0200
From: Nicolas Kaiser <nikai@nikai.net>
Subject: Re: [PATCH 11/12] vfs: increase shrinker batch size
Message-ID: <20110602113026.7291b1a7@absol.kitzblitz>
In-Reply-To: <1306998067-27659-12-git-send-email-david@fromorbit.com>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-12-git-send-email-david@fromorbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

Just noticed below two typos.

* Dave Chinner <david@fromorbit.com>:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now that the per-sb shrinker is responsible for shrinking 2 or more
> caches, increase the batch size to keep econmies of scale for

economies

(..)

>  Documentation/filesystems/vfs.txt |    5 +++++
>  fs/super.c                        |    1 +
>  2 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index dc732d2..2e26973 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -317,6 +317,11 @@ or bottom half).
>  	the VM is trying to reclaim under GFP_NOFS conditions, hence this
>  	method does not need to handle that situation itself.
>  
> +	Implementations must include conditional reschedule calls inside any
> +	scanning loop that is done. This allows the VFS to determine
> +	appropriate scan batch sizes without having to worry about whether
> +	implementations will cause holdoff problems due ot large batch sizes.

due to

Best regards,
Nicolas Kaiser

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
