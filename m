Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 59E906B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 10:13:22 -0500 (EST)
Date: Thu, 26 Jan 2012 09:13:16 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [v7 7/8] mm: only IPI CPUs to drain local pages if they exist
In-Reply-To: <1327572121-13673-8-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1201260912540.23426@router.home>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com> <1327572121-13673-8-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Milton Miller <miltonm@bga.com>

On Thu, 26 Jan 2012, Gilad Ben-Yossef wrote:

> Calculate a cpumask of CPUs with per-cpu pages in any zone
> and only send an IPI requesting CPUs to drain these pages
> to the buddy allocator if they actually have pages when
> asked to flush.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
