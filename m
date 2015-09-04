Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id BAFEB6B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 10:11:36 -0400 (EDT)
Received: by ioii196 with SMTP id i196so24901165ioi.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 07:11:36 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id p2si2470274igh.37.2015.09.04.07.11.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 07:11:36 -0700 (PDT)
Received: by iofh134 with SMTP id h134so25091293iof.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 07:11:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150904075945.GA31503@swordfish>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
	<20150903122949.78ee3c94@redhat.com>
	<20150904063528.GA29320@swordfish>
	<CA+55aFxOR06BiyH9nfFXzidFGr77R_BGp_xypjFQJSnv5c+_-g@mail.gmail.com>
	<20150904075945.GA31503@swordfish>
Date: Fri, 4 Sep 2015 07:11:35 -0700
Message-ID: <CA+55aFzs78Y0LS2FJG7Mrh6KBFxVnsBGSAySoi7SpR+EmmGpLg@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Dave Chinner <dchinner@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, Sep 4, 2015 at 12:59 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
>
> But I went through the corresponding slabinfo (I track slabinfo too); and yes,
> zero unused objects.

Ahh. I should have realized - the number you are actually tracking is
meaningless. The "unused objects" thing is not really tracked well.

/proc/slabinfo ends up not showing the percpu queue state, so things
look "used" when they are really just on the percpu queues for that
slab.So the "unused" number you are tracking is not really meaningful,
and the zeroes you are seeing is just a symptom of that: slabinfo
isn't "exact" enough.

So you should probably do the statistics on something that is more
meaningful: the actual number of pages that have been allocated (which
would be numslabs times pages-per-slab).

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
