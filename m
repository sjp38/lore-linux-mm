Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3756B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 02:13:52 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so46604797ioi.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 23:13:52 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id 194si12742497ioo.107.2015.09.02.23.13.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 23:13:52 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so41868774igb.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 23:13:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150903060247.GV1933@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
Date: Thu, 3 Sep 2015 09:13:51 +0300
Message-ID: <CAOJsxLHCXvravjnQESH4V6c2cT6Q61+xvG5UO4gB6u1DovnHcw@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 3, 2015 at 9:02 AM, Dave Chinner <dchinner@redhat.com> wrote:
> One of the reasons slab caches exist is to separate objects of
> identical characteristics from the heap allocator so that they are
> all grouped together in memory and so can be allocated/freed
> efficiently.  This helps prevent heap fragmentation, allows objects
> to pack as tightly together as possible, gives direct measurement of
> the number of objects, the memory usage, the fragmentation factor,
> etc. Containment of memory corruption is another historical reason
> for slab separation (proof: current memory debugging options always
> causes slab separation).
>
> Slab merging is the exact opposite of this - we're taking homogenous
> objects and mixing them with other homogneous containing different
> objects with different life times. Indeed, we are even mixing them
> back into the slabs used for the heap, despite the fact the original
> purpose of named slabs was to separate allocation from the heap...
>
> Don't get me wrong - this isn't necessarily bad - but I'm just
> pointing out that slab merging is doing the opposite of what slabs
> were originally intended for. Indeed, a lot of people use slab
> caches just because it's anice encapsulation, not for any specific
> performance, visibility or anti-fragmentation purposes.  I have no
> problems with automatically merging slabs created like this.

Yes, absolutely. Alternative to slab merging is to actually reduce the
number of caches we create in the first place and use kmalloc()
wherever possible.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
