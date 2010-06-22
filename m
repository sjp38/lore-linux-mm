Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 71D126B0071
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:26:47 -0400 (EDT)
Subject: Re: [PATCH V3 3/8] Cleancache: core ops functions and configuration
From: Dave Hansen <dave@sr71.net>
In-Reply-To: <20100621231939.GA19505@ca-server1.us.oracle.com>
References: <20100621231939.GA19505@ca-server1.us.oracle.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 22 Jun 2010 09:26:28 -0700
Message-ID: <1277223988.9782.20.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-21 at 16:19 -0700, Dan Magenheimer wrote:
> --- linux-2.6.35-rc2/include/linux/cleancache.h 1969-12-31 17:00:00.000000000 -0700
> +++ linux-2.6.35-rc2-cleancache/include/linux/cleancache.h      2010-06-21 14:45:18.000000000 -0600
> @@ -0,0 +1,88 @@
> +#ifndef _LINUX_CLEANCACHE_H
> +#define _LINUX_CLEANCACHE_H
> +
> +#include <linux/fs.h>
> +#include <linux/mm.h>
> +
> +struct cleancache_ops {
> +       int (*init_fs)(size_t);
> +       int (*init_shared_fs)(char *uuid, size_t);
> +       int (*get_page)(int, ino_t, pgoff_t, struct page *);
> +       void (*put_page)(int, ino_t, pgoff_t, struct page *);
> +       void (*flush_page)(int, ino_t, pgoff_t);
> +       void (*flush_inode)(int, ino_t);
> +       void (*flush_fs)(int);
> +};
> + 

How would someone go about testing this code?  Is there an example
cleancache implementation?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
