Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7556B0037
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:59:37 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so3456543pdj.36
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 06:59:37 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id v5si27739071pdj.234.2014.09.10.06.59.36
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 06:59:36 -0700 (PDT)
Date: Wed, 10 Sep 2014 08:59:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
In-Reply-To: <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1409100858470.23359@gentwo.org>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz> <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Kosina <jkosina@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>, Theodore Ts'o <tytso@mit.edu>

On Tue, 9 Sep 2014, Andrew Morton wrote:

> >
> > -	if (unlikely(ZERO_OR_NULL_PTR(objp)))
> > +	if (unlikely(ZERO_OR_NULL_PTR(objp) || IS_ERR(objp)))
> >  		return;
>
> kfree() is quite a hot path to which this will add overhead.  And we
> have (as far as we know) no code which will actually use this at
> present.

We could come up with a macro that does both. Basically if objp < 4086 or
so (signed comparison) then just return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
