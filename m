Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCFF6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:56:55 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id q200so1263467ykb.19
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 06:56:54 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id h21si8550747yhd.111.2014.09.10.06.56.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 06:56:54 -0700 (PDT)
Date: Wed, 10 Sep 2014 09:56:49 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <20140910135649.GB31903@thunk.org>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
 <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
 <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
 <20140909221138.2587d864.akpm@linux-foundation.org>
 <20140910063630.GM6549@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140910063630.GM6549@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>

On Wed, Sep 10, 2014 at 09:36:30AM +0300, Dan Carpenter wrote:
> On Tue, Sep 09, 2014 at 10:11:38PM -0700, Andrew Morton wrote:
> > On Wed, 10 Sep 2014 07:05:40 +0200 (CEST) Jiri Kosina <jkosina@suse.cz> wrote:
> > This is the sort of error which a static checker could find.  I wonder
> > if any of them do so.
> 
> Yes.  Ted asked me to add this to Smatch and that's how we found the
> problems in ext4.  I'll push it out later this week.  It won't find
> every single bug.
> 
> We have fixed the 8 bugs that Smatch found.

The ironic thing is that I asked Dan to add the feature to smatch
because I found two such bugs in ext4, and I suspected there would be
more.  Sure enough, it found four more such bugs, including two in a
recent commit where I had found the first two bugs --- and I had
missed the other two even though I was specifically looking for such
instances.  Oops.  :-)

Maybe we can add a debugging config option?  I think having static
checkers plus some kmalloc failure testing should be sufficient to
prevent these sorts of problem from showing up.

It would seem to me that this is the sort of thing that a static
checker should find reliably; Coverity has found things that were more
complex than what this should require, I think.  I don't know if they
would be willing to add something this kernel-specific, though.  (I've
added Dave Jones to the thread since he's been working a lot with
Coverity; Dave, what do you think?)

      	 	    		       - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
