Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1C56B005C
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:28:15 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id z11so7664822lbi.12
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 08:28:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si21833119lal.134.2014.09.10.08.28.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 08:28:14 -0700 (PDT)
Date: Wed, 10 Sep 2014 17:28:11 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
In-Reply-To: <20140910152104.GS6549@mwanda>
Message-ID: <alpine.LNX.2.00.1409101725340.5523@pobox.suse.cz>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz> <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org> <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz> <20140910140759.GC31903@thunk.org> <alpine.LNX.2.00.1409101625160.5523@pobox.suse.cz>
 <20140910152104.GS6549@mwanda>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 10 Sep 2014, Dan Carpenter wrote:

> > BTW if we stretch this argument a little bit more, we should also kill the 
> > ZERO_OR_NULL_PTR() check from kfree() and make it callers responsibility 
> > to perform the checking only if applicable ... we are currently doing a 
> > lot of pointless checking in cases where caller would be able to guarantee 
> > that the pointer is going to be non-NULL.
> 
> What you're saying is that we should remove the ZERO_SIZE_PTR
> completely.  ZERO_SIZE_PTR is a very useful idiom and also it's too late
> to remove it because everything depends on it.

I was just argumenting that if we care about single additional test in 
this path, the ZERO_OR_NULL_PTR() should have never been added at the 
first place, and the responsibility for checking should have been kept at 
callers.

Too late for this now, yes.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
