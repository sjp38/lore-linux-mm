Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id C53556B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:43:57 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id rl12so6056403iec.24
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 08:43:57 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id jd1si17899378icc.20.2014.09.10.08.43.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 08:43:56 -0700 (PDT)
Date: Wed, 10 Sep 2014 10:43:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
In-Reply-To: <alpine.LNX.2.00.1409101613500.5523@pobox.suse.cz>
Message-ID: <alpine.DEB.2.11.1409101042230.1654@gentwo.org>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz> <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org> <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz> <20140910140759.GC31903@thunk.org>
 <alpine.LNX.2.00.1409101613500.5523@pobox.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>

On Wed, 10 Sep 2014, Jiri Kosina wrote:

> Still, I believe that kernel shouldn't be just ignoring kfree(ERR_PTR)
> happening. Would something like the below be more acceptable?

CONFIG_DEBUG_SLAB is the wrong debugging option since it is used for
object debugging. This kind of patch would need CONFIG_DEBUG_VM I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
