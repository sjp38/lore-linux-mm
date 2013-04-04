Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 2C41C6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 22:00:36 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id hf12so1993713vcb.34
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 19:00:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com>
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
	<CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com>
	<alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com>
Date: Wed, 3 Apr 2013 19:00:34 -0700
Message-ID: <CA+55aFygozny+00y3hKAwkgg-6AWh0JpmqggmGcbraGrEhOkRg@mail.gmail.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler implementation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Wed, Apr 3, 2013 at 6:52 PM, David Rientjes <rientjes@google.com> wrote:
>
> The specification here says an access to this volatile quaified pointer is
> implementation defined

.. and my argument is that we don't care about paper standards, we
care about QUALITY OF IMPLEMENTATION.

If a compiler messes up volatile casts, the quality of implementation
is bad. There's just no excuse.

The compiler people can talk about how the paper standard allows it
until the cows come home. Why should we care? The compiler person is
still just making excuses for a bad implementation.

There is no sane alternative semantics to "volatile" that I can come
up with. Seriously. What meaning could "volatile" ever have that would
be sensible and break this?

Now, I do repeat: I don't like volatile. I think it has many problems,
and being underspecified is just one of them (the much deeper problem
is that the C standard attaches it to the data, not to the code, and
we then have to "fix" that by mis-using it as a cast).

So if some improved standard comes along, I'd happily use that. In the
meantime, we don't have any choice, do we? Seriously, you can talk
about paper standards until you are blue in the face, but since there
is no sane alternative to the volatile cast, what's the point, really?

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
