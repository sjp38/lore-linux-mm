Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 03EC06B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 10:13:28 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so24994644ioi.2
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 07:13:27 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id b7si2476576igf.27.2015.09.04.07.13.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 07:13:27 -0700 (PDT)
Date: Fri, 4 Sep 2015 09:13:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for
 4.3)
In-Reply-To: <20150904111038.4a428b03@redhat.com>
Message-ID: <alpine.DEB.2.11.1509040906280.30848@east.gentwo.org>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com> <20150903005115.GA27804@redhat.com> <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com> <20150903060247.GV1933@devil.localdomain> <20150903122949.78ee3c94@redhat.com>
 <alpine.DEB.2.11.1509031113450.24411@east.gentwo.org> <20150904111038.4a428b03@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Fri, 4 Sep 2015, Jesper Dangaard Brouer wrote:

> Thus, I could achieve the same performance results by tuning SLUB as I
> could with "slab_nomerge".  Maybe the advantage from "slab_nomerge" was
> just that I got my "own" per CPU structures, and this implicitly larger
> per CPU memory for myself?

Well if multiple slabs are merged then there is potential pressure on the
per node locks if huge amounts of objects are concurrently retrieved from
the per node partial lists by two different subsystems. So cache merging
can increase contention and thereby reduce performance. What you did with
tuning is to reduce that contention by increasing the per cpu pages that
do not require locks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
