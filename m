Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D38306B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 06:37:46 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1308097798.17300.142.camel@schen9-DESK>
References: <1308097798.17300.142.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 15 Jun 2011 12:36:40 +0200
Message-ID: <1308134200.15315.32.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On Tue, 2011-06-14 at 17:29 -0700, Tim Chen wrote:
> MOSBENCH test suite.

Argh, I'm trying to get this thing to run, but its all snake poo..

/me takes up a heavy club and goes snake hunting, should make a pretty
hat or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
