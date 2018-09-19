Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5678E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:28:03 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bg5-v6so2895398plb.20
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 11:28:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 82-v6sor3420342pfm.11.2018.09.19.11.28.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 11:28:02 -0700 (PDT)
Date: Wed, 19 Sep 2018 11:28:00 -0700
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v7 2/6] mm: export add_swap_extent()
Message-ID: <20180919182800.GK479@vader>
References: <cover.1536704650.git.osandov@fb.com>
 <bb1208575e02829aae51b538709476964f97b1ea.1536704650.git.osandov@fb.com>
 <20180919180909.GC18068@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180919180909.GC18068@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Wed, Sep 19, 2018 at 02:09:09PM -0400, Johannes Weiner wrote:
> On Tue, Sep 11, 2018 at 03:34:45PM -0700, Omar Sandoval wrote:
> > From: Omar Sandoval <osandov@fb.com>
> > 
> > Btrfs will need this for swap file support.
> > 
> > Signed-off-by: Omar Sandoval <osandov@fb.com>
> 
> That looks reasonable. After reading the last patch, it's somewhat
> understandable why you cannot simply implemnet ->bmap and use the
> generic activation code. But it would be good to explain the reason(s)
> for why you can't here briefly to justify this patch.

I'll rewrite it to:

Btrfs currently does not support swap files because swap's use of bmap
does not work with copy-on-write and multiple devices. See 35054394c4b3
("Btrfs: stop providing a bmap operation to avoid swapfile
corruptions"). However, the swap code has a mechanism for the filesystem
to manually add swap extents using add_swap_extent() from the
->swap_activate() aop. iomap has done this since 67482129cdab ("iomap:
add a swapfile activation function"). Btrfs will do the same in a later
patch, so export add_swap_extent().
