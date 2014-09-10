Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 13AB26B007D
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:40:14 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id z6so4684219yhz.29
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:40:13 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id k29si12939280yha.8.2014.09.10.12.40.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 12:40:13 -0700 (PDT)
Date: Wed, 10 Sep 2014 15:40:10 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <20140910194010.GE31903@thunk.org>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
 <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
 <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
 <20140910140759.GC31903@thunk.org>
 <alpine.LNX.2.00.1409101625160.5523@pobox.suse.cz>
 <20140910152104.GS6549@mwanda>
 <alpine.LNX.2.00.1409101725340.5523@pobox.suse.cz>
 <20140910155356.GT6549@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140910155356.GT6549@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Jiri Kosina <jkosina@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 10, 2014 at 06:53:56PM +0300, Dan Carpenter wrote:
> On Wed, Sep 10, 2014 at 05:28:11PM +0200, Jiri Kosina wrote:
> > 
> > Too late for this now, yes.
> 
> We could still introduce a __kfree_fast_path() which doesn't have
> checking.

Well, there certainly is precedence for that sort of thing.  There is
a bunch of code which uses __brelse(bh) instead of brelse(bh) when the
caller is sure that bh is a valid non-NULL pointer.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
