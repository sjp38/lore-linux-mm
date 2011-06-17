Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E70E86B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:06:01 -0400 (EDT)
Received: by yxp4 with SMTP id 4so1869435yxp.14
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 12:05:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308334963.17300.489.camel@schen9-DESK>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com> <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com> <1308334963.17300.489.camel@schen9-DESK>
From: Ray Lee <ray-lk@madrabbit.org>
Date: Fri, 17 Jun 2011 12:05:29 -0700
Message-ID: <BANLkTimNQm+Cq3nrHpWpBXTvDyDcreLPeg@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, Jun 17, 2011 at 11:22 AM, Tim Chen <tim.c.chen@linux.intel.com> wro=
te:
> For this patch, I've run it 10 times and got an average throughput of
> 104.9% compared with 2.6.39 vanilla baseline. =C2=A0Wide variations are s=
een
> run to run and the difference between max and min throughput is 52% of
> average value.

If the variations are that drastic, it's useful to include the
standard deviation of the mean for each kernel as well. I know it's
only 10 runs, but it's often useful to know if a slow but reliable
process is being replaced by a sometimes faster but more erratic one,
for example.

Just a thought.

~r.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
