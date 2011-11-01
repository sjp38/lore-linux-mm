Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F1E026B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 14:59:47 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 1 Nov 2011 14:49:53 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pA1ImuKF186718
	for <linux-mm@kvack.org>; Tue, 1 Nov 2011 14:48:56 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pA1ImWj8032640
	for <linux-mm@kvack.org>; Tue, 1 Nov 2011 16:48:34 -0200
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <bb0996fb-9b83-4de2-a1e4-d9c810c4b48a@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	 <75efb251-7a5e-4aca-91e2-f85627090363@default>
	 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
	 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
	 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
	 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
	 <20111028163053.GC1319@redhat.com>
	 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
	 <20138.62532.493295.522948@quad.stoffel.home>
	 <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default>
	 <1320048767.8283.13.camel@dabdike>
	 <424e9e3a-670d-4835-914f-83e99a11991a@default 1320142403.7701.62.camel@dabdike>
	 <bb0996fb-9b83-4de2-a1e4-d9c810c4b48a@default>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Nov 2011 11:48:14 -0700
Message-ID: <1320173294.15403.109.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Jonathan Corbet <corbet@lwn.net>

On Tue, 2011-11-01 at 11:10 -0700, Dan Magenheimer wrote:
> Case A) CONFIG_FRONTSWAP=n
> Case B) CONFIG_FRONTSWAP=y and no tmem backend registers
> Case C) CONFIG_FRONTSWAP=y and a tmem backend DOES register
...
> The point is that only Case C has possible interactions
> so Case A and Case B end-users and kernel developers need
> not worry about the maintenance. 

I'm personally evaluating this as if all the distributions would turn it
on.  I'm evaluating as if every one of my employer's systems ships with
it and as if it is =y my laptop.  Basically, I'm evaluating A/B/C and
only looking at the worst-case maintenance cost (C).  In other words,
I'm ignoring A/B and assuming wide use.

I'm curious where you expect to see the code get turned on and used
since we might be looking at this from different angles.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
