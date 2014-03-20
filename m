Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id A5CDA6B019E
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 04:47:53 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id e16so358890lan.30
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 01:47:52 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id gp1si934080lbc.168.2014.03.20.01.47.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 01:47:51 -0700 (PDT)
Received: by mail-lb0-f182.google.com with SMTP id n15so362288lbi.27
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 01:47:50 -0700 (PDT)
Date: Thu, 20 Mar 2014 12:47:48 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 3/6] shm: add memfd_create() syscall
Message-ID: <20140320084748.GK1728@moon>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
 <1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>, Pavel Emelyanov <xemul@parallels.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, Kristian =?iso-8859-1?Q?H=F8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Wed, Mar 19, 2014 at 08:06:48PM +0100, David Herrmann wrote:
> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
> that you can pass to mmap(). It explicitly allows sealing and
> avoids any connection to user-visible mount-points. Thus, it's not
> subject to quotas on mounted file-systems, but can be used like
> malloc()'ed memory, but with a file-descriptor to it.
> 
> memfd_create() does not create a front-FD, but instead returns the raw
> shmem file, so calls like ftruncate() can be used. Also calls like fstat()
> will return proper information and mark the file as regular file. Sealing
> is explicitly supported on memfds.
> 
> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
> subject to quotas and alike.

If I'm not mistaken in something obvious, this looks similar to /proc/pid/map_files
feature, Pavel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
