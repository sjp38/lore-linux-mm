Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 928106B000D
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 17:54:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u6-v6so109244pgr.2
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 14:54:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s135-v6sor486874pgs.317.2018.07.06.14.54.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 14:54:40 -0700 (PDT)
Date: Fri, 6 Jul 2018 14:54:37 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v6 7/7] fs/dcache: Allow deconfiguration of negative
 dentry code to reduce kernel size
Message-ID: <20180706215437.GA109361@gmail.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <1530905572-817-8-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530905572-817-8-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Fri, Jul 06, 2018 at 03:32:52PM -0400, Waiman Long wrote:
> The tracking and limit of negative dentries in a filesystem is a useful
> addition. However, for users who want to reduce the kernel size as much
> as possible, this feature will probably be on the chopping block. To
> suit those users, a default-y config option DCACHE_LIMIT_NEG_ENTRY is
> added so that the negative dentry tracking and limiting code can be
> configured out, if necessary.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  fs/Kconfig             | 10 ++++++++++
>  fs/dcache.c            | 33 ++++++++++++++++++++++++++++++++-
>  include/linux/dcache.h |  2 ++
>  kernel/sysctl.c        |  2 ++
>  4 files changed, 46 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index ac474a6..b521941 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -113,6 +113,16 @@ source "fs/autofs/Kconfig"
>  source "fs/fuse/Kconfig"
>  source "fs/overlayfs/Kconfig"
>  
> +#
> +# Track and limit the number of negative dentries allowed in the system.
> +#
> +config DCACHE_LIMIT_NEG_ENTRY
> +	bool "Track & limit negative dcache entries"
> +	default y
> +	help
> +	  This option enables the tracking and limiting of the total
> +	  number of negative dcache entries allowable in the filesystem.
> +

If there's going to be a config option for this, it should be documented
properly.  I.e., why would someone want to turn this on, or turn it off?  What
are the tradeoffs?  If unsure, should the user say y or n?

I think there are way too many config options that were meaningful to the person
writing the code but aren't meaningful to people configuring the kernel.

- Eric
