Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 34E1382FD8
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 00:41:25 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l126so234866557wml.0
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 21:41:25 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id q189si74711380wmd.74.2015.12.26.21.41.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 26 Dec 2015 21:41:23 -0800 (PST)
Date: Sun, 27 Dec 2015 05:41:17 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: fix noisy sparse warning in LIBCFS_ALLOC_PRE()
Message-ID: <20151227054117.GG20997@ZenIV.linux.org.uk>
References: <1451193162-20057-1-git-send-email-stillcompiling@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451193162-20057-1-git-send-email-stillcompiling@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joshua Clayton <stillcompiling@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

On Sat, Dec 26, 2015 at 09:12:42PM -0800, Joshua Clayton wrote:
> running sparse on drivers/staging/lustre results in dozens of warnings:
> include/linux/gfp.h:281:41: warning:
> odd constant _Bool cast (400000 becomes 1)
> 
> Use "!!" to explicitly convert the result to bool range.

... and the cast to bool is left in order to...?

> -	return (bool __force)(gfp_flags & __GFP_DIRECT_RECLAIM);
> +	return (bool __force)!!(gfp_flags & __GFP_DIRECT_RECLAIM);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
