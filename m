Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 41D7782F82
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 02:10:44 -0500 (EST)
Received: by lfaz4 with SMTP id z4so50401457lfa.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 23:10:43 -0800 (PST)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id p62si6862982lfb.210.2015.12.09.23.10.40
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 23:10:42 -0800 (PST)
Date: Thu, 10 Dec 2015 08:10:22 +0100
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
Message-ID: <20151210071022.GA31969@1wt.eu>
References: <20151209225148.GA14794@www.outflux.net> <20151210070635.GC31922@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210070635.GC31922@1wt.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 08:06:35AM +0100, Willy Tarreau wrote:
> Hi Kees,
> 
> Why not add a new file flag instead ?
> 
> Something like this (editing your patch by hand to illustrate) :
(...)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3aa514254161..409bd7047e7e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -913,3 +913,4 @@
>  #define FL_OFDLCK       1024    /* lock is "owned" by struct file */
>  #define FL_LAYOUT       2048    /* outstanding pNFS layout */
> +#define FL_DROP_PRIVS   4096    /* lest something weird decides that 2 is OK */

Crap, these ones are for locks, we need to use O_* instead
But anyway you get the idea, I mean there are probably many spare bits
overthere.

Another option I was thinking about was to change f_mode and detect the
change on close. But I don't know what to compare it against.

Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
