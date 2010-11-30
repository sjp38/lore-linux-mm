Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC2C56B0089
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:38:57 -0500 (EST)
Subject: Re: [thisops uV3 07/18] highmem: Use this_cpu_xx_return()
 operations
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1291145391.2904.247.camel@edumazet-laptop>
References: <20101130190707.457099608@linux.com>
	 <20101130190845.216537525@linux.com>
	 <1291144408.2904.232.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011301325180.3134@router.home>
	 <1291145391.2904.247.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 30 Nov 2010 20:38:30 +0100
Message-ID: <1291145910.32004.1166.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-11-30 at 20:29 +0100, Eric Dumazet wrote:
>=20
> well maybe a single prototype ;)
>=20
> static inline void kmap_atomic_idx_pop(void)
> {
> #ifdef CONFIG_DEBUG_HIGHMEM
>         int idx =3D __this_cpu_dec_return(__kmap_atomic_idx);
>         BUG_ON(idx < 0);
> #else
>       __this_cpu_dec(__kmap_atomic_idx);
> #endif
> }=20

Right, at least a consistent prototype, the above looks fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
