Date: Wed, 15 Apr 1998 11:11:07 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: I've got some patches to integrate...
In-Reply-To: <m11zuz4vm5.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.95.980415105437.839D-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Eric,

On 14 Apr 1998, Eric W. Biederman wrote:
...
> Anyhow I thought I'd bounce off what I had off this list and see what
> people thought of my ideas.  I started checking with Stepen Tweedie to
> see if he maintained the swap code and if I should send patches to
> him, or Linus.  And he said it should bounce what I have off of this
> list, and to start talks about integrating it.
...

Hmmm, before I make any silly mumblings, would you mind [re]sending a copy
of your patch to linux-mm?  (I've misplaced the copy I had, and linuxhq's
kernel archive isn't searchable right now.)  Linus probably won't want to
integrate them for 2.2, but perhaps we can start maintaining a set of
patches reasonably 'in sync' until 2.3 when they could be integrated. 
Hopefully that way they we can get people to provide a reasonable amount
of testing to the code. 

Which reminds me: Stephen, what's the state of your irq and smp patches
for page cache addition/removal.  I'm getting a bit more free time now, so
perhaps I can play with them a bit (maybe we should have a common cvs
tree...).

		-ben
