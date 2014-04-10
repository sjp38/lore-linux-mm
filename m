Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id AEAD26B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 15:49:51 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so4361273pbb.40
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:49:50 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id dg5si2779039pbc.265.2014.04.10.12.49.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Apr 2014 12:49:49 -0700 (PDT)
Date: Thu, 10 Apr 2014 19:45:38 +0000
From: Colin Walters <walters@verbum.org>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Message-Id: <1397159378.4434.1@mail.messagingengine.com>
In-Reply-To: <5346EDE8.2060004@amacapital.net>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<20140320153250.GC20618@thunk.org>
	<1397141388.16343.10@mail.messagingengine.com>
	<5346EDE8.2060004@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: tytso@mit.edu, David Herrmann <dh.herrmann@gmail.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, Kristian@thunk.org, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, mtk.manpages@gmail.com

On Thu, Apr 10, 2014 at 3:15 PM, Andy Lutomirski <luto@amacapital.net> 
wrote:
> 
> 
> COW links can do this already, I think.  Of course, you'll have to 
> use a
> filesystem that supports them.

COW is nice if the filesystem supports them, but my userspace code 
needs to be filesystem agnostic.  Because of that, the design for 
userspace simply doesn't allow arbitrary writes.

Instead, I have to painfully audit every rpm %post/dpkg postinst type 
script to ensure they break hardlinks, and furthermore only allow 
executing scripts that are known to do so.

But I think even in a btrfs world it'd still be useful to mark files as 
content-immutable.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
