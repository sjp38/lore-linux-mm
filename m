Date: Wed, 7 Jun 2000 18:31:30 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <393EBEB5.AEEFF501@reiser.to>
Message-ID: <Pine.LNX.4.21.0006071829440.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Hans Reiser wrote:
> "Stephen C. Tweedie" wrote:
> > On Wed, Jun 07, 2000 at 01:16:04PM -0700, Hans Reiser wrote:
> > > "Quintela Carreira Juan J." wrote:
> > > > If you need pages in the LRU cache only for getting notifications,
> > > > then change the system to send notifications each time that we are
> > > > short of memory.
> > >
> > > I think the right thing is for the filesystems to use the LRU code as templates
> > > from which they may vary or not from in implementing their subcaches with their
> > > own lists.  I say this for intuitive not concrete reasons.
> > 
> > Every time we have tried to keep the caches completely separate, we
> > have ended up losing the ability to balance the various caches against
> > each other.  The major advantage of a common set of LRU lists is that
> > it gives us a basis for a balanced VM.
> 
> If I understand Juan correctly, they fixed this issue.  Aging
> 1/64th of the cache for every cache evenly at every round of
> trying to free pages should be an excellent fix.  It should do
> just fine at the task of handling a system with both ext3 and
> reiserfs running.

Unfortunately it doesn't...

> Was this Juan's code that did this?  If so, kudos to him.

I believe Stephen made this code for 2.2, the code has served us
well but we've determined that having separate LRU queues just
isn't the way to go.

(explanation not repeated to avoid reader boredom)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
