From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Thu, 10 Jul 2003 00:59:57 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <200307082027.13857.phillips@arcor.de> <20030709222426.GA24923@mail.jlokier.co.uk>
In-Reply-To: <20030709222426.GA24923@mail.jlokier.co.uk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307100059.57398.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Davide Libenzi <davidel@xmailserver.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 10 July 2003 00:24, Jamie Lokier wrote:
> Daniel Phillips wrote:
> > We've got something better than we've had before, even though it doesn't
> > go as far as making true realtime processing available to normal users.
>
> Indeed.  But maybe true (bounded CPU) realtime, reliable, would more
> accurately reflect what the user actually wants for some apps?

No doubt about it.  Other OSes have it:

   http://www.chemie.fu-berlin.de/cgi-bin/man/sgi_irix?realtime+5

Hopefully in the next cycle, we will too.

I like your idea of allowing normal users to set SCHED_RR, but automatically 
placing some bound on cpu usage.  It's guaranteed not to break any existing 
programs.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
