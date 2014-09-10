Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 82B556B0037
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:27:44 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id x13so6214644qcv.13
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:27:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g69si18802116qgg.113.2014.09.10.07.27.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 07:27:28 -0700 (PDT)
Date: Wed, 10 Sep 2014 10:27:12 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <20140910142712.GA10785@redhat.com>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
 <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
 <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
 <20140909221138.2587d864.akpm@linux-foundation.org>
 <20140910063630.GM6549@mwanda>
 <20140910135649.GB31903@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140910135649.GB31903@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 10, 2014 at 09:56:49AM -0400, Theodore Ts'o wrote:

 > The ironic thing is that I asked Dan to add the feature to smatch
 > because I found two such bugs in ext4, and I suspected there would be
 > more.  Sure enough, it found four more such bugs, including two in a
 > recent commit where I had found the first two bugs --- and I had
 > missed the other two even though I was specifically looking for such
 > instances.  Oops.  :-)
 > 
 > Maybe we can add a debugging config option?  I think having static
 > checkers plus some kmalloc failure testing should be sufficient to
 > prevent these sorts of problem from showing up.
 > 
 > It would seem to me that this is the sort of thing that a static
 > checker should find reliably; Coverity has found things that were more
 > complex than what this should require, I think.  I don't know if they
 > would be willing to add something this kernel-specific, though.  (I've
 > added Dave Jones to the thread since he's been working a lot with
 > Coverity; Dave, what do you think?)

It *might* be possible to rig up something using their modelling 
functionality, but I've not managed to make that work to my ends in the past.

I suspect a runtime check would be more fruitful faster than they could
implement kernel specific checkers & roll them out.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
