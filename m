Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 600C76B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 22:18:28 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id mc17so1173850pbc.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 19:18:27 -0700 (PDT)
Date: Wed, 3 Apr 2013 19:18:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler
 implementation
In-Reply-To: <CA+55aFygozny+00y3hKAwkgg-6AWh0JpmqggmGcbraGrEhOkRg@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1304031902370.4709@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils> <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org> <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com> <20130403045814.GD4611@cmpxchg.org> <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com> <20130403143302.GL1953@cmpxchg.org>
 <alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com> <alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com> <CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com> <alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com>
 <CA+55aFygozny+00y3hKAwkgg-6AWh0JpmqggmGcbraGrEhOkRg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Wed, 3 Apr 2013, Linus Torvalds wrote:

> .. and my argument is that we don't care about paper standards, we
> care about QUALITY OF IMPLEMENTATION.
> 
> If a compiler messes up volatile casts, the quality of implementation
> is bad. There's just no excuse.
> 

I agreed, and I agreed when we had a "discussion" about the sign of a 
bitfield six years ago, but the key here is that I'm talking about meaning 
of the comment and not the compiler.  I'm trying to clear up any 
misconception that people have, and that's why it's a patch that modifies 
a comment and not source.

Those misconceptions exist, like it or not.  People have seen this 
ACCESS_ONCE() abstraction and think they can use it to solve concurrency 
issues in their own userland code with dereferences to shared objects.

> There is no sane alternative semantics to "volatile" that I can come
> up with. Seriously. What meaning could "volatile" ever have that would
> be sensible and break this?
> 
> Now, I do repeat: I don't like volatile. I think it has many problems,
> and being underspecified is just one of them (the much deeper problem
> is that the C standard attaches it to the data, not to the code, and
> we then have to "fix" that by mis-using it as a cast).
> 

I know you do and I know you contributed to having an entire 
volatile-considered-harmful doc in the tree, which is really a lecture on 
C rather than having anything specific to do with the kernel itself.  So 
I'm a little surpised that you wouldn't opt for being 100% explicit in one 
of its rare appearances.  It's easy to see you're no longer amused.

> So if some improved standard comes along, I'd happily use that. In the
> meantime, we don't have any choice, do we? Seriously, you can talk
> about paper standards until you are blue in the face, but since there
> is no sane alternative to the volatile cast, what's the point, really?
> 

Would you convert the definition of ACCESS_ONCE() to use the resulting 
feature from the gcc folks that would actually guarantee it in the 
compiler-gcc.h files?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
