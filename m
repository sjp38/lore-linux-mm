Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 158916B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 00:11:02 -0400 (EDT)
Date: Thu, 27 Oct 2011 23:10:58 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH v2 4/6] mm: Only IPI CPUs to drain local pages if they
 exist
In-Reply-To: <1319384922-29632-5-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1110272307110.14619@router.home>
References: <1319384922-29632-1-git-send-email-gilad@benyossef.com> <1319384922-29632-5-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: lkml@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Sun, 23 Oct 2011, Gilad Ben-Yossef wrote:

> +/* Which CPUs have per cpu pages  */
> +cpumask_var_t cpus_with_pcp;
> +static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);

This increases the cache footprint of a hot vm path. Is it possible to do
the same than what you did for slub? Run a loop over all zones when
draining to check for remaining pcp pages and build the set of cpus
needing IPIs temporarily while draining?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
