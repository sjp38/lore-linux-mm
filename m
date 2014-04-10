Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id C4F466B0036
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 15:15:57 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so4306224pbb.8
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:15:57 -0700 (PDT)
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
        by mx.google.com with ESMTPS id m8si2723055pbd.460.2014.04.10.12.15.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 12:15:56 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so4377080pab.33
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:15:56 -0700 (PDT)
Message-ID: <5346EDE8.2060004@amacapital.net>
Date: Thu, 10 Apr 2014 12:15:52 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>	<20140320153250.GC20618@thunk.org> <1397141388.16343.10@mail.messagingengine.com>
In-Reply-To: <1397141388.16343.10@mail.messagingengine.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Walters <walters@verbum.org>, tytso@mit.edu
Cc: David Herrmann <dh.herrmann@gmail.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, Kristian@thunk.org, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, mtk.manpages@gmail.com

On 04/10/2014 07:45 AM, Colin Walters wrote:
> On Thu, Mar 20, 2014 at 11:32 AM, tytso@mit.edu wrote:
>>
>> Looking at your patches, and what files you are modifying, you are
>> enforcing this in the low-level file system.
> 
> I would love for this to be implemented in the filesystem level as
> well.  Something like the ext4 immutable bit, but with the ability to
> still make hardlinks would be *very* useful for OSTree.  And anyone else
> that uses hardlinks as a data source.  The vserver people do something
> similiar:
> http://linux-vserver.org/util-vserver:Vhashify
> 
> At the moment I have a read-only bind mount over /usr, but what I really
> want is to make the individual objects in the object store in
> /ostree/repo/objects be immutable, so even if a user or app navigates
> out to /sysroot they still can't mutate them (or the link targets in the
> visible /usr).

COW links can do this already, I think.  Of course, you'll have to use a
filesystem that supports them.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
