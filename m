Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 254BF6B0073
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 02:05:21 -0500 (EST)
From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH v6 3/8] tile: move tile to use generic on_each_cpu_mask
In-Reply-To: <1326040026-7285-4-git-send-email-gilad@benyossef.com>
References: <1326040026-7285-4-git-send-email-gilad@benyossef.com>
Date: Wed, 11 Jan 2012 01:04:12 -0600
Message-ID: <1326265452_1660@mail4.comsite.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>, Kosaki Motohiro <kosaki.motohiro@gmail.com>


On Sun, 8 Jan 2012 about 11:28:05 EST, Gilad Ben-Yossef wrote:
> The API is the same as the tile private one, so just remove
> the private version of the functions

Except their up version also forgot local_irq_disable and local_irq_enable
like the arm.

Also as I said, merge 1-3 after review to avoid bisection build errors.

milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
