Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D6AC46B0069
	for <linux-mm@kvack.org>; Sun, 30 Oct 2011 16:06:35 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Sun, 30 Oct 2011 14:06:35 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9UK6CAd128010
	for <linux-mm@kvack.org>; Sun, 30 Oct 2011 14:06:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9UK6BdU009421
	for <linux-mm@kvack.org>; Sun, 30 Oct 2011 14:06:12 -0600
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <3ac142d4-a4ca-4a24-bf0b-69a90bd1d1a0@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	 <75efb251-7a5e-4aca-91e2-f85627090363@default>
	 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
	 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
	 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
	 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
	 <20111028163053.GC1319@redhat.com>
	 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
	 <20138.62532.493295.522948@quad.stoffel.home>
	 <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default 20139.5644.583790.903531@quad.stoffel.home>
	 <3ac142d4-a4ca-4a24-bf0b-69a90bd1d1a0@default>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 30 Oct 2011 13:06:02 -0700
Message-ID: <1320005162.15403.14.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Jonathan Corbet <corbet@lwn.net>

On Sun, 2011-10-30 at 12:18 -0700, Dan Magenheimer wrote:
> > since they're the ones who will have to understand this stuff and know
> > how to maintain it.  And keeping this maintainable is a key goal.
> 
> Absolutely agree.  Count the number of frontswap lines that affect
> the current VM core code and note also how they are very clearly
> identified.  It really is a very VERY small impact to the core VM
> code (e.g. in the files swapfile.c and page_io.c). 

Granted, the impact on the core VM in lines of code is small.  But, I
think the behavioral impact is potentially huge since tmem's hooks add
non-trivial amounts of framework underneath the VM in core paths.  In
zcache's case, this means a bunch of allocations and an entirely new
allocator memory allocator being used in the swap paths.

We're certainly still shaking bugs out of the interactions there like
with zcache_direct_reclaim_lock.  Granted, that's not a
tmem/frontswap/cleancache bug, but it does speak to the difficulty and
subtlety of writing one of those frameworks underneath the tmem API.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
