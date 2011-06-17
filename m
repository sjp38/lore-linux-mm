Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1438E6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 12:49:21 -0400 (EDT)
Received: from mail-ww0-f45.google.com (mail-ww0-f45.google.com [74.125.82.45])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5HGkKWx006628
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:46:23 -0700
Received: by wwi36 with SMTP id 36so2354032wwi.26
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:46:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308310080.2355.19.camel@twins>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com> <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com> <1308310080.2355.19.camel@twins>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Jun 2011 09:46:00 -0700
Message-ID: <BANLkTin3onK+43LxODfbu-sdm-pFut0TKw@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, Jun 17, 2011 at 4:28 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> Something like so? Compiles and runs the benchmark in question.

Oh, and can you do this with a commit log and sign-off, and I'll put
it in my "anon_vma-locking" branch that I have. I'm not going to
actually merge that branch into mainline until I've seen a few more
acks or more testing by Tim.

But if Tim's numbers hold up (-32% to +15% performance by just the
first one, and +15% isn't actually an improvement since tmpfs
read-ahead should have gotten us to +66%), I think we have to do this
just to avoid the performance regression.

                                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
