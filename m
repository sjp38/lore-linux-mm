Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id B57E46B020F
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 11:33:08 -0400 (EDT)
Received: by mail-yh0-f51.google.com with SMTP id f10so994589yha.38
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:33:08 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id x66si2549110yhd.26.2014.03.20.08.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 08:33:07 -0700 (PDT)
Date: Thu, 20 Mar 2014 11:32:51 -0400
From: tytso@mit.edu
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Message-ID: <20140320153250.GC20618@thunk.org>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, Kristian@thunk.org, =?iso-8859-1?Q?H=F8gsberg_=3Ckrh=40bitplanet=2Enet=3E?=@thunk.org, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Wed, Mar 19, 2014 at 08:06:45PM +0100, David Herrmann wrote:
> 
> This series introduces the concept of "file sealing". Sealing a file restricts
> the set of allowed operations on the file in question. Multiple seals are
> defined and each seal will cause a different set of operations to return EPERM
> if it is set. The following seals are introduced:
> 
>  * SEAL_SHRINK: If set, the inode size cannot be reduced
>  * SEAL_GROW: If set, the inode size cannot be increased
>  * SEAL_WRITE: If set, the file content cannot be modified

Looking at your patches, and what files you are modifying, you are
enforcing this in the low-level file system.

Why not make sealing an attribute of the "struct file", and enforce it
at the VFS layer?  That way all file system objects would have access
to sealing interface, and for memfd_shmem, you can't get another
struct file pointing at the object, the security properties would be
identical.

Cheers,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
