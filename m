Date: Thu, 14 Sep 2000 19:03:06 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: Running out of memory in 1 easy step
In-Reply-To: <20000914212004.A1304@cistron.nl>
Message-ID: <Pine.LNX.4.10.10009141857470.24004-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wichert Akkerman <wichert@cistron.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Not likely, there were still a couple hundreds of megabytes free and
> the process had allocated about 1.5Gb of data.

mmaping 1 to 4096 bytes consumes 8K from your address space:
one for the mmaped page, and one (virtual) guard page (unless 
you use MAP_FIXED, of course.)  4G / 8K is approximately the 458878
you reported.  actually, since maps begin at 1G, I would have
expected you to run out sooner...

regards, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
