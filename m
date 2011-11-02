Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B087E6B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 04:53:46 -0400 (EDT)
Date: Wed, 2 Nov 2011 03:53:42 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH v2 4/6] mm: Only IPI CPUs to drain local pages if they
 exist
In-Reply-To: <CAOtvUMd8Z_jbs__+cVG2+ZkPZLqGkJGym402RMRYGDDjT73bkg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1111020352210.23788@router.home>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com> <1319385413-29665-5-git-send-email-gilad@benyossef.com> <4EAAD351.70805@redhat.com> <CAOtvUMd8Z_jbs__+cVG2+ZkPZLqGkJGym402RMRYGDDjT73bkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1496498453-1320224024=:23788"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1496498453-1320224024=:23788
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 29 Oct 2011, Gilad Ben-Yossef wrote:

> >> +/* Which CPUs have per cpu pages =A0*/
> >> +cpumask_var_t cpus_with_pcp;
> >> +static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);
> >
> > Does the flushing happen so frequently that it is worth keeping this
> > state on a per-cpu basis, or would it be better to check each CPU's
> > pcp info and assemble a cpumask at flush time like done in patch 5?
> >
>
> No, I don't  believe it is frequent at all. I will try to re-work the
> patch as suggested.

The draining of the pcp pages is done from the vmstat callback which
occurs every second. Only if there is something to clean in the caches
will the flush happen.


---1463811839-1496498453-1320224024=:23788--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
