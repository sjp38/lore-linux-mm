Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id D253D6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:26:49 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id u10so4414037lbd.29
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:26:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id we6si21733006lbb.77.2014.09.10.07.26.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 07:26:48 -0700 (PDT)
Date: Wed, 10 Sep 2014 16:26:46 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
In-Reply-To: <20140910140759.GC31903@thunk.org>
Message-ID: <alpine.LNX.2.00.1409101625160.5523@pobox.suse.cz>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz> <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org> <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz> <20140910140759.GC31903@thunk.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>

On Wed, 10 Sep 2014, Theodore Ts'o wrote:

> I'd much rather depending on better testing and static checkers to fix 
> them, since kfree *is* a hot path.

BTW if we stretch this argument a little bit more, we should also kill the 
ZERO_OR_NULL_PTR() check from kfree() and make it callers responsibility 
to perform the checking only if applicable ... we are currently doing a 
lot of pointless checking in cases where caller would be able to guarantee 
that the pointer is going to be non-NULL.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
