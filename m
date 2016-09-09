Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18A1A6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 10:32:52 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i184so59193750itf.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 07:32:52 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id w58si2272292otd.197.2016.09.09.07.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 07:32:51 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id s131so137480835oie.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 07:32:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAB3-ZyQ4Mbj2g6b6Zt4pGLhE7ew9O==rNbUgAaPLYSwdRK3Czw@mail.gmail.com>
References: <CAB3-ZyQ4Mbj2g6b6Zt4pGLhE7ew9O==rNbUgAaPLYSwdRK3Czw@mail.gmail.com>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 9 Sep 2016 16:32:49 +0200
Message-ID: <CAJfpeguMfoK+foKxUeSLOw0aD=U+ya6BgpRm2XnFfKx3w2Nfpg@mail.gmail.com>
Subject: Re: [fuse-devel] Kernel panic under load
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Antonio SJ Musumeci <trapexit@spawn.link>
Cc: fuse-devel <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

On Fri, Sep 9, 2016 at 3:34 PM, Antonio SJ Musumeci <trapexit@spawn.link> wrote:
> https://gist.github.com/bauruine/3bc00075c4d0b5b3353071d208ded30f
> https://github.com/trapexit/mergerfs/issues/295
>
> I've some users which are having issues with my filesystem where the
> system's load increases and then the kernel panics.
>
> Has anyone seen this before?

Quite possibly this is caused by fuse, but the BUG is deep in mm
territory and I have zero clue about what it means.

Hannes,  can you please look a the above crash in mm/workingset.c?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
