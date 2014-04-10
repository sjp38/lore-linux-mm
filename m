Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id DEDFC6B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:50:01 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so3963733pdj.36
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:50:01 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id ug9si2343151pab.253.2014.04.10.07.50.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Apr 2014 07:50:00 -0700 (PDT)
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 8692C21520
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:49:59 -0400 (EDT)
Date: Thu, 10 Apr 2014 14:45:48 +0000
From: Colin Walters <walters@verbum.org>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Message-Id: <1397141388.16343.10@mail.messagingengine.com>
In-Reply-To: <20140320153250.GC20618@thunk.org>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<20140320153250.GC20618@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu
Cc: David Herrmann <dh.herrmann@gmail.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, Kristian@thunk.org, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, mtk.manpages@gmail.com

On Thu, Mar 20, 2014 at 11:32 AM, tytso@mit.edu wrote:
> 
> Looking at your patches, and what files you are modifying, you are
> enforcing this in the low-level file system.

I would love for this to be implemented in the filesystem level as 
well.  Something like the ext4 immutable bit, but with the ability to 
still make hardlinks would be *very* useful for OSTree.  And anyone 
else that uses hardlinks as a data source.  The vserver people do 
something similiar:
http://linux-vserver.org/util-vserver:Vhashify

At the moment I have a read-only bind mount over /usr, but what I 
really want is to make the individual objects in the object store in 
/ostree/repo/objects be immutable, so even if a user or app navigates 
out to /sysroot they still can't mutate them (or the link targets in 
the visible /usr).




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
