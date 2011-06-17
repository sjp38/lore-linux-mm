Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 51DF16B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 18:34:56 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p5HMYmIS025187
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:34:53 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz37.hot.corp.google.com with ESMTP id p5HMYkBg009830
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:34:47 -0700
Received: by pzk36 with SMTP id 36so2335547pzk.20
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:34:46 -0700 (PDT)
Date: Fri, 17 Jun 2011 15:34:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] TMPFS: Add "tmpfs" to the Kconfig prompt to make it
 obvious.
In-Reply-To: <alpine.DEB.2.02.1106171641470.15335@localhost6.localdomain6>
Message-ID: <alpine.LSU.2.00.1106171531400.20805@sister.anvils>
References: <alpine.DEB.2.02.1106171641470.15335@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, 17 Jun 2011, Robert P. J. Day wrote:
> 
> Add the leading word "tmpfs" to the Kconfig string to make it
> blindingly obvious that this selection refers to tmpfs.
> 
> Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

Acked-by: Hugh Dickins <hughd@google.com>

> 
> ---
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 19891aa..b406da6 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -109,7 +109,7 @@ source "fs/proc/Kconfig"
>  source "fs/sysfs/Kconfig"
> 
>  config TMPFS
> -	bool "Virtual memory file system support (former shm fs)"
> +	bool "Tmpfs virtual memory file system support (former shm fs)"
>  	depends on SHMEM
>  	help
>  	  Tmpfs is a file system which keeps all files in virtual memory.
> 
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
