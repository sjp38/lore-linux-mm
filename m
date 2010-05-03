Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5E3B86007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 15:32:32 -0400 (EDT)
Date: Mon, 3 May 2010 21:32:23 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
Message-ID: <20100503193223.GA27796@elf.ucw.cz>
References: <1272591924.23895.807.camel@nimitz>
 <4BDA8324.7090409@redhat.com>
 <084f72bf-21fd-4721-8844-9d10cccef316@default>
 <4BDB026E.1030605@redhat.com>
 <4BDB18CE.2090608@goop.org>
 <4BDB2069.4000507@redhat.com>
 <3a62a058-7976-48d7-acd2-8c6a8312f10f@default>
 <4BDD9BD3.2080301@redhat.com>
 <f392dc83-f5a3-4048-ab4d-758225d16547@default4BDE8D76.3000703@redhat.com>
 <74c69226-4678-4b9b-bfeb-1490c8f5636d@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <74c69226-4678-4b9b-bfeb-1490c8f5636d@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Avi Kivity <avi@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>


> > If block layer overhead is a problem, go ahead and optimize it instead
> > of adding new interfaces to bypass it.  Though I expect it wouldn't be
> > needed, and if any optimization needs to be done it is in the swap
> > layer.
> > Optimizing swap has the additional benefit of improving performance on
> > flash-backed swap.
> >  :
> > What happens when no tmem is available?  you swap to a volume.  That's
> > the disk size needed.
> >  :
> > You're dynamic swap is limited too.  And no, no guest modifications.
> 
> You keep saying you are going to implement all of the dynamic features
> of frontswap with no changes to the guest and no copying and no
> host-swapping.  You are being disingenuous.  VMware has had a lot

I don't see why no copying is a requirement. I believe requirement
should be "it is fast enough".
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
