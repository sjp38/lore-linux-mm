Date: Thu, 11 Jan 2001 09:42:23 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Subtle MM bug
Message-ID: <20010111094223.C25375@redhat.com>
References: <Pine.LNX.4.10.10101091618110.2815-100000@penguin.transmeta.com> <Pine.LNX.4.21.0101110116370.8924-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0101110116370.8924-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Thu, Jan 11, 2001 at 01:30:18AM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jan 11, 2001 at 01:30:18AM -0200, Marcelo Tosatti wrote:
> 
> On Tue, 9 Jan 2001, Linus Torvalds wrote:
> 
> > So one "conditional aging" algorithm might just be something as simple as
> 
> I've done a very easy conditional aging patch (I dont think doing new
> functions to scan the active list and the pte's is necessary)

You still need to decay the bg_page_aging counter a little somewhere,
otherwise if you've been running a long-lived workload which keeps
most of memory recently activated, you'll build up such a large
counter that going idle will still age everything to zero.

This might be as simple as clamping the value of the counter to some
arbitrary maximum value such as num_physpages.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
