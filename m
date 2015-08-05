Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id D00DD6B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 14:39:16 -0400 (EDT)
Received: by qgj62 with SMTP id 62so11345931qgj.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 11:39:16 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id 141si6709617qhg.26.2015.08.05.11.39.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 11:39:15 -0700 (PDT)
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <20150805162436.GD25159@twins.programming.kicks-ass.net>
In-Reply-To: <20150805162436.GD25159@twins.programming.kicks-ass.net>
Mime-Version: 1.0 (1.0)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <81C750EC-F4D4-4890-894A-1D92E5CF3A31@rjmx.net>
From: Ron Murray <rjmx@rjmx.net>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
Date: Wed, 5 Aug 2015 14:38:57 -0400
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>





> On Aug 5, 2015, at 12:24, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
> On Wed, Aug 05, 2015 at 11:09:22AM -0500, Christoph Lameter wrote:
>>> [1.] One line summary of the problem:
>>>    4.1.4 -- Kernel Panic on shutdown
>>=20
>> This is a kfree of an object that was not allocated via the slab
>> allocators or was already freed. If you boot with the kernel command line=

>> argument "slub_debug" then you could get some more information. Could als=
o
>> be that memory was somehow corrupted.
>>=20
>> The backtrace shows that this is a call occurring in the
>> scheduler.
>>=20
>> CCing scheduler developers.
>=20
> I'll go have a look; but the obvious question is, what's the last known
> good kernel?
>=20
>>=20
>>=20

4.0.x series still work for me. I had wondered about a memory fault (on the i=
dea that a small shift in memory position might hit the fault), but memtest8=
6 turned up nothing.

I will try re-compiling to use the SLAB allocator and see if that helps.

 .....Ron

--
Ron Murray <rjmx@rjmx.net>
PGP Fingerprint: 0ED0 C1D1 615C FCCE 7424  9B27 31D8 AED5 AF6D 0D4A


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
