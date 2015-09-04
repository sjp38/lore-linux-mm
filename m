Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3536B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 03:01:42 -0400 (EDT)
Received: by igbut12 with SMTP id ut12so6632277igb.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 00:01:42 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id j9si1609530ige.71.2015.09.04.00.01.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 00:01:41 -0700 (PDT)
Received: by ioii196 with SMTP id i196so13903239ioi.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 00:01:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150904063528.GA29320@swordfish>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
	<20150903122949.78ee3c94@redhat.com>
	<20150904063528.GA29320@swordfish>
Date: Fri, 4 Sep 2015 00:01:41 -0700
Message-ID: <CA+55aFxOR06BiyH9nfFXzidFGr77R_BGp_xypjFQJSnv5c+_-g@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Dave Chinner <dchinner@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Thu, Sep 3, 2015 at 11:35 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
>
> Out of curiosity, I did some quite simple-minded
> "slab_nomerge = 0" vs. "slab_nomerge = 1" tests today on my old
> x86_64 box (4gigs of RAM, ext4, 4.2.0-next-20150903):

So out of interest, was this slab or slub? Also, how repeatable is
this? The memory usage between two boots tends to be rather fragile -
some of the bigger slab users are dentries and inodes, and various
filesystem scanning events will end up skewing things a _lot_.

But if it turns out that the numbers are pretty stable, and sharing
really doesn't save memory, then that is certainly a big failure. I
think Christoph did much of his work for bigger machines where one of
the SLAB issues was the NUMA overhead, and who knows - maybe it worked
well for the load and machine in question, but not necessarily
elsewhere.

Interesting.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
