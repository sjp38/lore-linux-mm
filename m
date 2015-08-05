Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7AD6B0253
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 15:27:29 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so18700491qkb.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 12:27:29 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id e80si7087295qka.22.2015.08.05.12.27.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 12:27:28 -0700 (PDT)
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <20150805162436.GD25159@twins.programming.kicks-ass.net> <81C750EC-F4D4-4890-894A-1D92E5CF3A31@rjmx.net> <alpine.DEB.2.11.1508051405130.30653@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1508051405130.30653@east.gentwo.org>
Mime-Version: 1.0 (1.0)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <12261B75-F5F5-4332-A7E9-490251E4DC37@rjmx.net>
From: Ron Murray <rjmx@rjmx.net>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
Date: Wed, 5 Aug 2015 15:27:14 -0400
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>


> On Aug 5, 2015, at 15:06, Christoph Lameter <cl@linux.com> wrote:
>=20
>> On Wed, 5 Aug 2015, Ron Murray wrote:
>>=20
>> I will try re-compiling to use the SLAB allocator and see if that helps.
>=20
> The slab allocator does not have the same diagnostic capabilities to
> detect the memory corruption issues.
>=20

True. But if I don't get a crash with it, it might tell us whether the fault=
 lies with SLUB or not. And I will still try with SLUB and the debug option (=
probably tonight, after I get home).

 .....Ron

--
Ron Murray <rjmx@rjmx.net>
PGP Fingerprint: 0ED0 C1D1 615C FCCE 7424  9B27 31D8 AED5 AF6D 0D4A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
