Date: Wed, 26 Jul 2000 12:02:38 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Inter-zone swapping
Message-ID: <20000726120238.F8224@redhat.com>
References: <20000725143833.E1396@redhat.com> <Pine.LNX.4.10.10007251743530.11616-100000@coffee.psychology.mcmaster.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10007251743530.11616-100000@coffee.psychology.mcmaster.ca>; from hahn@coffee.psychology.mcmaster.ca on Tue, Jul 25, 2000 at 05:46:10PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Cesar Eduardo Barros <cesarb@nitnet.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jul 25, 2000 at 05:46:10PM -0400, Mark Hahn wrote:
> 
> doesn't good page coloring need this ability, as well, 
> to move around which physical page is backing a virtual one?
> guess it depends on whether the arch does cache lookups based
> on p or v addresses...

Yes.  Fortunately, very few archs do this the wrong way. :-)  Where
they do, page colouring is desperately important, but you can usually
do that within zones rather than having to balance between zones (it's
a similar problem but working along a different axis).

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
