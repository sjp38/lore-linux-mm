Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA4336B0263
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 04:54:29 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e20so111556872itc.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 01:54:29 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id 6si22944823ots.284.2016.09.21.01.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 01:54:29 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id a62so52348203oib.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 01:54:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAB3-ZyR=V2fPYVGOs=j=O_-zTh45KAXXdxQ-LO9Q9qAnUR-_-w@mail.gmail.com>
References: <CAB3-ZyQ4Mbj2g6b6Zt4pGLhE7ew9O==rNbUgAaPLYSwdRK3Czw@mail.gmail.com>
 <CAJfpeguMfoK+foKxUeSLOw0aD=U+ya6BgpRm2XnFfKx3w2Nfpg@mail.gmail.com>
 <20160909194239.GA16056@cmpxchg.org> <CAJfpegv3Hk3WtGG0gQ+TGpyoH0CoTf=um8gUdV8KA-ZneQ8+JA@mail.gmail.com>
 <20160914143102.GA1445@cmpxchg.org> <CAB3-ZyR=V2fPYVGOs=j=O_-zTh45KAXXdxQ-LO9Q9qAnUR-_-w@mail.gmail.com>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 21 Sep 2016 10:54:28 +0200
Message-ID: <CAJfpeguf4gQX6VpmEU_H9E_nnvhJyH+QgqJZZYBLvddkPap7SQ@mail.gmail.com>
Subject: Re: [fuse-devel] Kernel panic under load
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Antonio SJ Musumeci <trapexit@spawn.link>
Cc: Johannes Weiner <hannes@cmpxchg.org>, fuse-devel <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Sep 14, 2016 at 4:51 PM, Antonio SJ Musumeci
<trapexit@spawn.link> wrote:
> I was unable to reproduce the problem but I'll forward this on to my user
> and see if they can test it.
>
> I imagine the users would prefer it backported though they have worked
> around the problem by turning off splicing.

Since users were reporting this on Ubuntu 16.04, it would make sense
to open a bug against that kernel (backport doens't seem difficult,
but it's not trivial either, and I'm really not familiar with that
code).

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
