Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 82F136B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 15:14:03 -0500 (EST)
Message-ID: <1326399227.2442.209.camel@twins>
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 12 Jan 2012 21:13:47 +0100
In-Reply-To: <20120112182644.GE11715@one.firstfloor.org>
References: <1326380820.2442.186.camel@twins>
	 <20120112182644.GE11715@one.firstfloor.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2012-01-12 at 19:26 +0100, Andi Kleen wrote:
> This would break the numactl testsuite.
>=20
How so? The userspace output will still contain the field, we'll simply
always print 0.

But if you want I can provide a patch for numactl.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
