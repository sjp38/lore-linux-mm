Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 0BF446B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 20:38:08 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id hr11so1943239vcb.17
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 17:38:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
	<alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
	<alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
	<alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
	<20130403041447.GC4611@cmpxchg.org>
	<alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
	<20130403045814.GD4611@cmpxchg.org>
	<CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
	<20130403143302.GL1953@cmpxchg.org>
	<alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com>
Date: Wed, 3 Apr 2013 17:38:07 -0700
Message-ID: <CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler implementation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Wed, Apr 3, 2013 at 5:00 PM, David Rientjes <rientjes@google.com> wrote:
> The dereference of a volatile-qualified pointer does not guarantee that it
> cannot be optimized by the compiler to be loaded multiple times into
> memory even if assigned to a local variable by C99 or any previous C
> standard.
>
> Clarify the comment of ACCESS_ONCE() to state explicitly that its current
> form relies on the compiler's implementation to work correctly.

This is utter bullshit and garbage.

Any compiler that thinks it can load something through a "volatile"
pointer multiple times is SHIT. We don't add these kinds of comments
to make excuses for crap, we call out such compilers and tell people
not to use the utter crap they are.

The fact is, "volatile" is pretty much the only thing that can do this
(and there are no sane alternate semantics that a compiler *could* use
for a volatile cast), and no amount of weasel-wording by compiler
apologists makes it not so. I'm not a huge fan of volatile as a C
feature, but I'm even less of a fan of people trying to make excuses
for bad compilers.

Is there a reason why you want to add this idiotic comment? Is there a
compiler that actually dismisses a volatile cast? If so, warn us about
that kind of crap, and I'll happily make it very clear that people
should not use the piece-of-shit compiler in question. Making excuses
for that kind of compiler behavior is absolutely the last thing we
should do.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
