Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 955176B004A
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 00:48:36 -0400 (EDT)
Received: from mail-vx0-f169.google.com (mail-vx0-f169.google.com [209.85.220.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5I4m1aq022033
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 21:48:01 -0700
Received: by vxg38 with SMTP id 38so2034149vxg.14
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 21:48:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1106171509100.20144@sister.anvils>
References: <1308097798.17300.142.camel@schen9-DESK> <1308156337.2171.23.camel@laptop>
 <1308163398.17300.147.camel@schen9-DESK> <1308169937.15315.88.camel@twins>
 <4DF91CB9.5080504@linux.intel.com> <1308172336.17300.177.camel@schen9-DESK>
 <1308173849.15315.91.camel@twins> <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com>
 <1308255972.17300.450.camel@schen9-DESK> <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com>
 <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com> <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com>
 <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com> <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
 <1308310080.2355.19.camel@twins> <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com>
 <alpine.LSU.2.00.1106171040460.7018@sister.anvils> <BANLkTim3vo0vpovV=5sU=GLxkotheB=Ryg@mail.gmail.com>
 <1308334688.12801.19.camel@laptop> <1308335557.12801.24.camel@laptop>
 <BANLkTimStT22tA2YkeuYBzarnnWTnMjiKQ@mail.gmail.com> <alpine.LSU.2.00.1106171509100.20144@sister.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Jun 2011 21:47:40 -0700
Message-ID: <BANLkTimsWSR=pob28f=pb9mK9f-_zUBrOA@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, Jun 17, 2011 at 3:20 PM, Hugh Dickins <hughd@google.com> wrote:
>
> Yes, that fixed the lockdep issue, and ran nicely under load for an hour.

Ok, nobody screamed or complained, so the thing is now merged and pushed out.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
