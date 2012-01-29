Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id A1BC66B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 03:25:47 -0500 (EST)
Received: by vbbfd1 with SMTP id fd1so2813712vbb.14
        for <linux-mm@kvack.org>; Sun, 29 Jan 2012 00:25:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1327591185.2446.102.camel@twins>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
Date: Sun, 29 Jan 2012 10:25:46 +0200
Message-ID: <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Jan 26, 2012 at 5:19 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
>
> On Thu, 2012-01-26 at 12:01 +0200, Gilad Ben-Yossef wrote:
> > Gilad Ben-Yossef (8):
> > =A0 smp: introduce a generic on_each_cpu_mask function
> > =A0 arm: move arm over to generic on_each_cpu_mask
> > =A0 tile: move tile to use generic on_each_cpu_mask
> > =A0 smp: add func to IPI cpus based on parameter func
> > =A0 slub: only IPI CPUs that have per cpu obj to flush
> > =A0 fs: only send IPI to invalidate LRU BH when needed
> > =A0 mm: only IPI CPUs to drain local pages if they exist
>
> These patches look very nice!
>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>

Thank you :-)

If this is of interest, I keep a list tracking global IPI and global
task schedulers sources in the core kernel here:
https://github.com/gby/linux/wiki.

I plan to visit all these potential interference source to see if
something can be done to lower their effect on
isolated CPUs over time.

>
> > =A0 mm: add vmstat counters for tracking PCP drains
> >
> I understood from previous postings this patch wasn't meant for
> inclusion, if it is, note that cpumask_weight() is a potentially very
> expensive operation.

Right. The only purpose of the patch is to show the usefulness
of the previous patch in the series. It is not meant for mainline.

Thanks,
Gilad



--
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
