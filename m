Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDEE6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 07:15:11 -0500 (EST)
From: Ed Tomlinson <edt@aei.ca>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Date: Tue, 08 Nov 2011 07:15:04 -0500
Message-ID: <15917317.H6lYS7chMM@grover>
In-Reply-To: <201529.1320618774@turing-police.cc.vt.edu>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default> <20139.5644.583790.903531@quad.stoffel.home> <201529.1320618774@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: John Stoffel <john@stoffel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Sunday 06 November 2011 17:32:54 Valdis.Kletnieks@vt.edu wrote:
> On Fri, 28 Oct 2011 16:52:28 EDT, John Stoffel said:
> > Dan> "WHY" this is such a good idea is the same as WHY it is useful to
> > Dan> add RAM to your systems. 
> >
> > So why would I use this instead of increasing the physical RAM?
> 
> You're welcome to buy me a new laptop that has a third DIMM slot. :)
> 
> There's a lot of people running hardware that already has the max amount of
> supported RAM, and who for budget or legacy-support reasons can't easily do a
> forklift upgrade to a new machine.

I've got three boxes with this problem here.  Hense my support for frontswap/cleancache.

Ed

> > if I've got a large system which cannot physically use any more
> > memory, then it might be worth my while to use TMEM to get more
> > performance out of this expensive hardware.
> 
> It's not always a large system....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
