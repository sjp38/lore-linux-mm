Date: Wed, 10 Jul 2002 17:42:41 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH][RFT](2) minimal rmap for 2.5 - akpm tested
In-Reply-To: <20020710193545.272bedab.sebastian.droege@gmx.de>
Message-ID: <Pine.LNX.4.44L.0207101741380.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sebastian Droege <sebastian.droege@gmx.de>
Cc: linux-kernel@vger.kernel.org, akpm@zip.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jul 2002, Sebastian Droege wrote:
> On Sat, 6 Jul 2002 02:31:38 -0300 (BRT)
> Rik van Riel <riel@conectiva.com.br> wrote:
>
> > If you have some time left this weekend and feel brave,
> > please test the patch which can be found at:
> >
> > 	http://surriel.com/patches/2.5/2.5.25-rmap-akpmtested

> after running your patch some time I have to say that the old VM
> implementation and the full rmap patch (by Craig Kulesa) was better. The
> system becomes very slow and has to swap in too much after some uptime
> (4 hours - 2 days) and memory intensive tasks...
> Maybe this happens only to me but it's fully reproducable

It's a known problem with use-once. Users of plain 2.4.18
are complaining about it, too.

This is something to touch on after the rmap mechanism
has been merged, Linus has indicated that he wants to merge
the thing in small bits so that's what we'll be doing ;)

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
