Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 836319000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 03:36:45 -0400 (EDT)
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Sep 2011 09:36:05 +0200
In-Reply-To: <CAOJsxLEHHJyPnCngQceRW04PLKFa3RUQEbc3rLwiOPXa7XZNeQ@mail.gmail.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	 <1316940890-24138-6-git-send-email-gilad@benyossef.com>
	 <CAOJsxLEHHJyPnCngQceRW04PLKFa3RUQEbc3rLwiOPXa7XZNeQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317022565.9084.60.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

On Mon, 2011-09-26 at 09:54 +0300, Pekka Enberg wrote:
>=20
> AFAICT, flush_all() isn't all that performance sensitive. Why do we
> want to reduce IPIs here?=20

Because it can wake up otherwise idle CPUs, wasting power. Or for the
case I care more about, unnecessarily perturb a CPU that didn't actually
have anything to flush but was running something, introducing jitter.

on_each_cpu() things are bad when you have a ton of CPUs (which is
pretty normal these days).=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
