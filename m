Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C558E6B005D
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 21:15:09 -0500 (EST)
Date: Sun, 16 Dec 2012 02:15:08 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: resend--[PATCH]  improve read ahead in kernel
Message-ID: <20121216021508.GA3629@dcvr.yhbt.net>
References: <50C4B4E7.60601@intel.com>
 <50C6AB45.606@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C6AB45.606@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xtu4 <xiaobing.tu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-tip-commits@vger.kernel.org, linux-mm@kvack.org, di.zhang@intel.com

xtu4 <xiaobing.tu@intel.com> wrote:
> resend it, due to format error
> 
> Subject: [PATCH] when system in low memory scenario, imaging there is a mp3
>  play, ora video play, we need to read mp3 or video file
>  from memory to page cache,but when system lack of memory,
>  page cache of mp3 or video file will be reclaimed.once read
>  in memory, then reclaimed, it will cause audio or video
>  glitch,and it will increase the io operation at the same
>  time.

To me, this basically describes how POSIX_FADV_NOREUSE should work.
I would like to have this ability via fadvise (and not CONFIG_).

Also, I think your patch has too many #ifdefs to be accepted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
