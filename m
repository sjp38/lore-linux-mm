Date: Thu, 28 Sep 2000 07:12:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.0-t9p7 and mmap002 - freeze
In-Reply-To: <Pine.Linu.4.10.10009280803050.1233-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0009280710230.1814-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: Roger Larsson <roger.larsson@norran.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2000, Mike Galbraith wrote:
> On Wed, 27 Sep 2000, Roger Larsson wrote:
> 
> > Tried latest patch with the same result - freeze...
> 
> Ditto.

I'm finally back from Linux Kongress and Linux Expo and
will look at the latest tree and integrate the fixes I
made while on the road later today (after I get some
sleep).

I have fixed this particular bug, which was caused by
us moving unfreeable pages to the inactive_dirty list
and back again, while not accomplishing anything useful.

The fix for this is trivial and I'll post it later
today (cleaned up and working in the current source
tree).

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
