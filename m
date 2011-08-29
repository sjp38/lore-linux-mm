Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CB556900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 08:33:12 -0400 (EDT)
Subject: Re: [PATCH 1/2] mm: convert k{un}map_atomic(p, KM_type) to
 k{un}map_atomic(p)
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 29 Aug 2011 14:33:05 +0200
In-Reply-To: <20110826204053.GA3408@elliptictech.com>
References: <1314346676.6486.25.camel@minggr.sh.intel.com>
	 <1314349096.26922.21.camel@twins>
	 <20110826124239.fc503491.akpm@linux-foundation.org>
	 <20110826204053.GA3408@elliptictech.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314621185.2816.16.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Bowler <nbowler@elliptictech.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org

On Fri, 2011-08-26 at 16:40 -0400, Nick Bowler wrote:
> > Extra marks will be awarded for
> > working out how to make unconverted code generate a compile warning ;)
>=20
> It's possible to (ab)use the C preprocessor to accomplish this sort of
> thing.  For instance, consider the following:
>=20
>   #include <stdio.h>
>=20
>   int foo(int x)
>   {
>      return x;
>   }
>=20
>   /* Deprecated; call foo instead. */
>   static inline int __attribute__((deprecated)) foo_unconverted(int x, in=
t unused)
>   {
>      return foo(x);
>   }
>=20
>   #define PASTE(a, b) a ## b
>   #define PASTE2(a, b) PASTE(a, b)
>  =20
>   #define NARG_(_9, _8, _7, _6, _5, _4, _3, _2, _1, n, ...) n
>   #define NARG(...) NARG_(__VA_ARGS__, 9, 8, 7, 6, 5, 4, 3, 2, 1, :)
>=20
>   #define foo1(...) foo(__VA_ARGS__)
>   #define foo2(...) foo_unconverted(__VA_ARGS__)
>   #define foo(...) PASTE2(foo, NARG(__VA_ARGS__)(__VA_ARGS__))

Very neat ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
