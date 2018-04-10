Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D87576B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:30:27 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e68so11382442iod.6
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 10:30:27 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id s132-v6si688816its.28.2018.04.10.10.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 10:30:26 -0700 (PDT)
Date: Tue, 10 Apr 2018 12:30:23 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180410165054.GC3614@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804101228170.29384@nuc-kabylake>
References: <20180410125351.15837-1-willy@infradead.org> <fee8a8bc-3db5-a66a-33cb-0729143ba615@gmail.com> <20180410165054.GC3614@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, 10 Apr 2018, Matthew Wilcox wrote:

> If we want to get rid of the concept of constructors, it's doable,
> but somebody needs to do the work to show what the effects will be.

How do you envision dealing with the SLAB_TYPESAFE_BY_RCU slab caches?
Those must have a defined state of the objects at all times and a constructor is
required for that. And their use of RCU is required for numerous lockless
lookup algorithms in the kernhel.
