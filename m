Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id CC0D06B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 10:20:06 -0500 (EST)
Message-ID: <1327591185.2446.102.camel@twins>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 26 Jan 2012 16:19:45 +0100
In-Reply-To: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, 2012-01-26 at 12:01 +0200, Gilad Ben-Yossef wrote:
> Gilad Ben-Yossef (8):
>   smp: introduce a generic on_each_cpu_mask function
>   arm: move arm over to generic on_each_cpu_mask
>   tile: move tile to use generic on_each_cpu_mask
>   smp: add func to IPI cpus based on parameter func
>   slub: only IPI CPUs that have per cpu obj to flush
>   fs: only send IPI to invalidate LRU BH when needed
>   mm: only IPI CPUs to drain local pages if they exist

These patches look very nice!

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>


>   mm: add vmstat counters for tracking PCP drains
>=20
I understood from previous postings this patch wasn't meant for
inclusion, if it is, note that cpumask_weight() is a potentially very
expensive operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
