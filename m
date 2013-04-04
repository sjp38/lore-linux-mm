Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 937616B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 15:53:36 -0400 (EDT)
Received: by mail-vb0-f51.google.com with SMTP id x19so1578738vbf.38
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 12:53:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1304041209330.19501@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
	<20130403041447.GC4611@cmpxchg.org>
	<alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
	<20130403045814.GD4611@cmpxchg.org>
	<CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
	<20130403143302.GL1953@cmpxchg.org>
	<alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com>
	<CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com>
	<alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com>
	<CA+55aFygozny+00y3hKAwkgg-6AWh0JpmqggmGcbraGrEhOkRg@mail.gmail.com>
	<alpine.DEB.2.02.1304031902370.4709@chino.kir.corp.google.com>
	<CA+55aFxUxL-Lt2UUCwvgZxYNSA182TdhxC3RdHss00wOb8_LqA@mail.gmail.com>
	<alpine.DEB.2.02.1304032127070.32444@chino.kir.corp.google.com>
	<CA+55aFw_krUFFpocLOcvuANODoCJiF=QSUQeED9Xa_fLt3Gv1w@mail.gmail.com>
	<alpine.DEB.2.02.1304041209330.19501@chino.kir.corp.google.com>
Date: Thu, 4 Apr 2013 12:53:35 -0700
Message-ID: <CA+55aFwVbnh1W6OGhVEi-OtM4OnGvk6+bAr8MGjCpvFuE3FLoA@mail.gmail.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler implementation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Thu, Apr 4, 2013 at 12:40 PM, David Rientjes <rientjes@google.com> wrote:
>
> I said in the previous email that you'd do this solely to rely on a
> well-defined semantic rather than reading paragraphs of comments that
> we're developing.

What's "well-defined" about it? It's implementation-defined in both cases.

IOW, why do you think "__builtin_access_once(x)" is fundamentally
different from "(*(volatile type *)&(x))"? Both would be equally
dependent on the compiler implementation, and I'd argue that it would
be much nicer if gcc just automatically turned the existing volatile
code internally into the builtin version (and then didn't even bother
to expose that builtin), since if they are willing to do the built-in,
they clearly acknowledge the need for this kind of behavior in the
first place.

See what I'm arguing? If a compiler writer is acknowledging that this
kind of "access once with good semantics through a pointer" is needed
and useful (and in the presense of IO and threading, a compiler writer
that doesn't acknowledge that is a moron), then _why_ would that same
compiler writer then argue against just doing that for volatile
pointers?

What's so magically bad about "volatile" that would be solved by a
totally new and nonstandard builtin?

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
