Subject: Re: [PATCH] Prevent OOM from killing init
References: <E14gVQf-00056B-00@the-village.bc.nu> <l0313030eb6e156f24437@[192.168.239.101]>
From: ebiederman@lnxi.com (Eric W. Biederman)
Date: 23 Mar 2001 16:26:31 -0700
In-Reply-To: Jonathan Morton's message of "Fri, 23 Mar 2001 19:45:26 +0000"
Message-ID: <m3snk4gj88.fsf@DLT.linuxnetworx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Martin Dalecki <dalecki@evision-ventures.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "James A. Sutherland" <jas88@cam.ac.uk>, Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jonathan Morton <chromi@cyberspace.org> writes:

> >It would make much sense to make the oom killer
> >leave not just root processes alone but processes belonging to a UID
> >lower
> >then a certain value as well (500). This would be:
> >
> >1. Easly managable by the admin. Just let oracle/www and analogous users
> >   have a UID lower then let's say 500.
> 
> That sounds vaguely sensible.  However, make it a "much less likely" rather
> than an "impossible", otherwise we end up with an unkillable runaway root
> process killing everything else in userland.
> 
> I'm still in favour of a failing malloc(), and I'm currently reading a bit
> of source and docs to figure out where this should be done and why it isn't
> done now.  So far I've found the overcommit_memory flag, which looks kinda
> promising.

Lookup mlock & mlock_all they will handle the single process case.

Of course if you OOM you still have problems but that should make
them much harder to trigger.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
