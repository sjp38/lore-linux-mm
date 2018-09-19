Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 910BF8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:09:12 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id p142-v6so335281ywe.15
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 11:09:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 138-v6sor2239731yws.542.2018.09.19.11.09.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 11:09:11 -0700 (PDT)
Date: Wed, 19 Sep 2018 14:09:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v7 2/6] mm: export add_swap_extent()
Message-ID: <20180919180909.GC18068@cmpxchg.org>
References: <cover.1536704650.git.osandov@fb.com>
 <bb1208575e02829aae51b538709476964f97b1ea.1536704650.git.osandov@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bb1208575e02829aae51b538709476964f97b1ea.1536704650.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Tue, Sep 11, 2018 at 03:34:45PM -0700, Omar Sandoval wrote:
> From: Omar Sandoval <osandov@fb.com>
> 
> Btrfs will need this for swap file support.
> 
> Signed-off-by: Omar Sandoval <osandov@fb.com>

That looks reasonable. After reading the last patch, it's somewhat
understandable why you cannot simply implemnet ->bmap and use the
generic activation code. But it would be good to explain the reason(s)
for why you can't here briefly to justify this patch.
