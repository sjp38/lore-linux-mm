Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1607C6B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:46:01 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r19so11301007iod.7
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 10:46:01 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id 102si2221870ioh.144.2018.04.10.10.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 10:46:00 -0700 (PDT)
Date: Tue, 10 Apr 2018 12:45:56 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180410173841.GD3614@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804101244290.29559@nuc-kabylake>
References: <20180410125351.15837-1-willy@infradead.org> <fee8a8bc-3db5-a66a-33cb-0729143ba615@gmail.com> <20180410165054.GC3614@bombadil.infradead.org> <alpine.DEB.2.20.1804101228170.29384@nuc-kabylake> <20180410173841.GD3614@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, 10 Apr 2018, Matthew Wilcox wrote:

> > How do you envision dealing with the SLAB_TYPESAFE_BY_RCU slab caches?
> > Those must have a defined state of the objects at all times and a constructor is
> > required for that. And their use of RCU is required for numerous lockless
> > lookup algorithms in the kernhel.
>
> Not at all times.  Only once they've been used.  Re-constructing them
> once they've been used might break the rcu typesafety, I suppose ...
> would need to examine the callers.

Objects can be freed and reused and still be accessed from code that
thinks the object is the old and not the new object....
