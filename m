Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0BF476B004A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 09:04:56 -0400 (EDT)
Date: Fri, 24 Sep 2010 15:02:17 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
Message-ID: <20100924130216.GA1810@ucw.cz>
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.comc, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi!

> There seems to be an epidemic spreading around.  People get the idea
> in their heads that the kernel caches are evil.  They eat too much
> memory, and there's no way to set a size limit on them!  Stupid
> kernel!

Its worse. IIRC android actually uses it in production. And, IIRC akpm
told me that drop_caches does not include enough locking to be
safe. If that's still the case, it should be documented.

> -As this is a non-destructive operation and dirty objects are not freeable, the
> -user should run `sync' first.
> +This is a non-destructive operation and will not free any dirty objects.
> +To increase the number of objects freed by this operation, the user may run
> +`sync' prior to writing to /proc/sys/vm/drop_caches.  This will minimize the
> +number of dirty objects on the system and create more candidates to be
> +dropped.
> +
> +This file is not a means to control the growth of the various kernel caches
> +(inodes, dentries, pagecache, etc...)  These objects are automatically
> +reclaimed by the kernel when memory is needed elsewhere on the system.
> +
> +Outside of a testing or debugging environment, use of
> +/proc/sys/vm/drop_caches is not recommended.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
