Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7D35A6B010E
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 20:04:30 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id u7so7883623qaz.13
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 17:04:30 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 17si39229752qgg.124.2014.11.11.17.04.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 17:04:29 -0800 (PST)
Date: Tue, 11 Nov 2014 19:04:26 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
In-Reply-To: <20141111165331.152562c12f03716334e2cfa0@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1411111903080.9204@gentwo.org>
References: <bug-87891-27@https.bugzilla.kernel.org/> <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org> <20141112004419.GA8075@js1304-P5Q-DELUXE> <20141111165331.152562c12f03716334e2cfa0@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Tue, 11 Nov 2014, Andrew Morton wrote:

> Well, attempting to fix it up and continue is nice, but we can live
> with the BUG.
>
> Not knowing which bit was set is bad.

Could we change BUG_ON to diplay the value? This keeps on coming up.

If you want to add this to the slab allocators then please add to
mm/slab_common.c and refer to it from the other allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
