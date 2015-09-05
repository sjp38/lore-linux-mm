Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1D96B0038
	for <linux-mm@kvack.org>; Sat,  5 Sep 2015 16:33:06 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so55862776ioi.2
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 13:33:05 -0700 (PDT)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id a17si6484425ioe.56.2015.09.05.13.33.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Sep 2015 13:33:05 -0700 (PDT)
Received: by ioii196 with SMTP id i196so55878673ioi.3
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 13:33:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150905020907.GA1431@swordfish>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
	<20150903122949.78ee3c94@redhat.com>
	<20150904063528.GA29320@swordfish>
	<CA+55aFxOR06BiyH9nfFXzidFGr77R_BGp_xypjFQJSnv5c+_-g@mail.gmail.com>
	<20150904075945.GA31503@swordfish>
	<CA+55aFzs78Y0LS2FJG7Mrh6KBFxVnsBGSAySoi7SpR+EmmGpLg@mail.gmail.com>
	<20150905020907.GA1431@swordfish>
Date: Sat, 5 Sep 2015 13:33:04 -0700
Message-ID: <CA+55aFw609MpnZPdecjxHxLRQsHp2fM+vUj0KtHPC9sTm78FRw@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Dave Chinner <dchinner@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, Sep 4, 2015 at 7:09 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
>
> Aha... Didn't know that, sorry.

Hey, I didn't react to it either. until you pointed out the oddity of
"no free slab memory" Very easy to overlook.

> ... And those are sort of interesting. I was expecting to see more
> diverged behaviours.
>
> Attached.

So I'm not sure how really conclusive these graphs are, but they are
certainly fun to look at. So I have a few reactions:

  - that 'nomerge' spike at roughly 780s is interesting. I wonder why
it does that.

 - it would be interesting to see - for example - which slabs are the
top memory users, and not _just_ the total (it could clarify the
spike, for example). That's obviously something that works much better
for the no-merge case, but could your script be changed to show (say)
the "top 5 slabs". Showing all of them would probably be too messy,
but "top 5" could be interesting.

 - assuming the times are comparable, it looks like 'merge' really is
noticeably faster. But that might just be noise too, so this may not
be real data.

 - regardless of how meaningful the graphs are, and whether they
really tell us anything, I do like the concept, and I'd love to see
people do things like this more often. Visualization to show behavior
is great.

That last point in particular means that if you scripted this and your
scripts aren't *too* ugly and not too tied to your particular setup, I
think it would perhaps not be a bad idea to encourage plots like this
by making those kinds of scripts available in the kernel tree.  That's
particularly true if you used something like the tools/testing/ktest/
scripts to run these things automatically (which can be a *big* issue
to show that something is actually stable across multiple boots, and
see the variance).

So maybe these graphs are meaningful, and maybe they aren't. But I'd
still like to see more of them ;)

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
