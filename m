Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id D29486B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 09:55:27 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so16979250igb.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 06:55:27 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id g184si2370804ioe.134.2015.09.04.06.55.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 06:55:26 -0700 (PDT)
Date: Fri, 4 Sep 2015 08:55:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for
 4.3)
In-Reply-To: <20150904032607.GX1933@devil.localdomain>
Message-ID: <alpine.DEB.2.11.1509040849460.30848@east.gentwo.org>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com> <20150903005115.GA27804@redhat.com> <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com> <20150903060247.GV1933@devil.localdomain>
 <CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com> <20150904032607.GX1933@devil.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Fri, 4 Sep 2015, Dave Chinner wrote:

> There are generic cases where it hurts, so no justification should
> be needed for those cases...

Inodes and dentries have constructors. These slabs are not mergeable and
will never be because they have cache specific code to be executed on the
object.

> Really, we don't need some stupidly high bar to jump over here -
> whether merging should be allowed can easily be answered with a
> simple question: "Does the slab have a shrinker or does it back a
> mempool?" If the answer is yes then using SLAB_SHRINKER or
> SLAB_MEMPOOL to trigger the no-merge case doesn't need any more
> justification from subsystem maintainers at all.

The slab shrinkers do not use mergeable slab caches.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
