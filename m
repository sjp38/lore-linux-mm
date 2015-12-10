Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2675982F7A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 23:14:54 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id c201so14230715wme.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 20:14:54 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id d4si42372677wmf.31.2015.12.09.20.14.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 20:14:53 -0800 (PST)
Date: Thu, 10 Dec 2015 04:14:24 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
Message-ID: <20151210041424.GD20997@ZenIV.linux.org.uk>
References: <20151209225148.GA14794@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209225148.GA14794@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 09, 2015 at 02:51:48PM -0800, Kees Cook wrote:
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3aa514254161..409bd7047e7e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -872,6 +872,7 @@ struct file {
>  	struct list_head	f_tfile_llink;
>  #endif /* #ifdef CONFIG_EPOLL */
>  	struct address_space	*f_mapping;
> +	bool			f_remove_privs;

NAK.  If anything, such things belong in ->f_flags.  _If_ this is worth
doing at all, that is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
