Date: Tue, 10 Jul 2007 15:12:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/10] Remove the SLOB allocator for 2.6.23
In-Reply-To: <20070710120224.GP11115@waste.org>
Message-ID: <Pine.LNX.4.64.0707101510410.5490@schroedinger.engr.sgi.com>
References: <20070708034952.022985379@sgi.com> <20070708035018.074510057@sgi.com>
 <20070708075119.GA16631@elte.hu> <20070708110224.9cd9df5b.akpm@linux-foundation.org>
 <4691A415.6040208@yahoo.com.au> <84144f020707090404l657a62c7x89d7d06b3dd6c34b@mail.gmail.com>
 <Pine.LNX.4.64.0707090907010.13970@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0707101049230.23040@sbz-30.cs.Helsinki.FI> <469342DC.8070007@yahoo.com.au>
 <84144f020707100231p5013e1aer767562c26fc52eeb@mail.gmail.com>
 <20070710120224.GP11115@waste.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-1284435424-1184105558=:5490"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com, corey.d.gough@intel.com, Denis Vlasenko <vda.linux@googlemail.com>, Erik Andersen <andersen@codepoet.org>
List-ID: <linux-mm.kvack.org>

---1700579579-1284435424-1184105558=:5490
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 10 Jul 2007, Matt Mackall wrote:

> following as the best MemFree numbers after several boots each:
>=20
> SLAB: 54796
> SLOB: 55044
> SLUB: 53944
> SLUB: 54788 (debug turned off)

That was without "slub_debug" as a parameter or with !CONFIG_SLUB_DEBUG?

Data size and code size will decrease if you compile with=20
!CONFIG_SLUB_DEBUG. slub_debug on the command line governs if debug=20
information is used.

> These numbers bounce around a lot more from boot to boot than I
> remember, so take these numbers with a grain of salt.
>=20
> Disabling the debug code in the build gives this, by the way:
>=20
> mm/slub.c: In function =FF=FFinit_kmem_cache_node=FF=FF:
> mm/slub.c:1873: error: =FF=FFstruct kmem_cache_node=FF=FF has no member n=
amed
> =FF=FFfull=FF=FF

A fix for that is in Andrew's tree.
---1700579579-1284435424-1184105558=:5490--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
