Message-ID: <393EBEB5.AEEFF501@reiser.to>
Date: Wed, 07 Jun 2000 14:29:25 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva> <20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica> <393EAD84.A4BB6BD9@reiser.to> <20000607215436.F30951@redhat.com>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Quintela Carreira Juan J." <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Wed, Jun 07, 2000 at 01:16:04PM -0700, Hans Reiser wrote:
> 
> > "Quintela Carreira Juan J." wrote:
> > > If you need pages in the LRU cache only for getting notifications,
> > > then change the system to send notifications each time that we are
> > > short of memory.
> >
> > I think the right thing is for the filesystems to use the LRU code as templates
> > from which they may vary or not from in implementing their subcaches with their
> > own lists.  I say this for intuitive not concrete reasons.
> 
> Every time we have tried to keep the caches completely separate, we
> have ended up losing the ability to balance the various caches against
> each other.  The major advantage of a common set of LRU lists is that
> it gives us a basis for a balanced VM.
> 
> Cheers,
>  Stephen

If I understand Juan correctly, they fixed this issue.  Aging 1/64th of the
cache for every cache evenly at every round of trying to free pages should be an
excellent fix.  It should do just fine at the task of handling a system with
both ext3 and reiserfs running.

Was this Juan's code that did this?  If so, kudos to him.

Hans
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
