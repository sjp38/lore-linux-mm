From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Thu, 10 Jul 2003 00:17:44 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <Pine.LNX.4.55.0307071007140.4704@bigblue.dev.mcafeelabs.com> <20030707193628.GA10836@mail.jlokier.co.uk>
In-Reply-To: <20030707193628.GA10836@mail.jlokier.co.uk>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200307082027.13857.phillips@arcor.de>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>, Davide Libenzi <davidel@xmailserver.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 07 July 2003 21:36, Jamie Lokier wrote:
> Davide Libenzi wrote:
> > The *application* has to hint the scheduler, not the user.
>
> Agreed.
>
> (I think the user/PAM idea came up for the same sort of reason that
> only console users are able to open /dev/cdrom: asking for extra
> resource (in this case low latency is a resource) might be something
> you'd restrict to console users.

I frequently run Zinf over ssh, to a machine that's connected to speakers.

> But that is a very separate question from how do we get low latency to work
> at all!)

We've got something better than we've had before, even though it doesn't go as 
far as making true realtime processing available to normal users.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
