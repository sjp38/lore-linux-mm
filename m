Date: Wed, 9 Jul 2003 23:24:26 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: 2.5.74-mm1
Message-ID: <20030709222426.GA24923@mail.jlokier.co.uk>
References: <20030703023714.55d13934.akpm@osdl.org> <Pine.LNX.4.55.0307071007140.4704@bigblue.dev.mcafeelabs.com> <20030707193628.GA10836@mail.jlokier.co.uk> <200307082027.13857.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200307082027.13857.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Davide Libenzi <davidel@xmailserver.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> > (I think the user/PAM idea came up for the same sort of reason that
> > only console users are able to open /dev/cdrom: asking for extra
> > resource (in this case low latency is a resource) might be something
> > you'd restrict to console users.
> 
> I frequently run Zinf over ssh, to a machine that's connected to speakers.

I do similar things.  I also read /dev/cdrom over ssh, which is not
permitted by the default security policy.  I.e. it's a userspace
policy issue.

> We've got something better than we've had before, even though it doesn't go as 
> far as making true realtime processing available to normal users.

Indeed.  But maybe true (bounded CPU) realtime, reliable, would more
accurately reflect what the user actually wants for some apps?

Just a thought,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
