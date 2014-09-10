Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 964116B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:54:10 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so8564641pdj.30
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 08:54:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i7si28340699pat.139.2014.09.10.08.54.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 08:54:09 -0700 (PDT)
Date: Wed, 10 Sep 2014 18:53:56 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <20140910155356.GT6549@mwanda>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
 <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
 <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
 <20140910140759.GC31903@thunk.org>
 <alpine.LNX.2.00.1409101625160.5523@pobox.suse.cz>
 <20140910152104.GS6549@mwanda>
 <alpine.LNX.2.00.1409101725340.5523@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1409101725340.5523@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 10, 2014 at 05:28:11PM +0200, Jiri Kosina wrote:
> 
> Too late for this now, yes.

We could still introduce a __kfree_fast_path() which doesn't have
checking.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
