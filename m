Date: Wed, 7 Jun 2000 21:54:36 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607215436.F30951@redhat.com>
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva> <20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica> <393EAD84.A4BB6BD9@reiser.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <393EAD84.A4BB6BD9@reiser.to>; from hans@reiser.to on Wed, Jun 07, 2000 at 01:16:04PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Quintela Carreira Juan J." <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 01:16:04PM -0700, Hans Reiser wrote:

> "Quintela Carreira Juan J." wrote:
> > If you need pages in the LRU cache only for getting notifications,
> > then change the system to send notifications each time that we are
> > short of memory.
> 
> I think the right thing is for the filesystems to use the LRU code as templates
> from which they may vary or not from in implementing their subcaches with their
> own lists.  I say this for intuitive not concrete reasons.

Every time we have tried to keep the caches completely separate, we 
have ended up losing the ability to balance the various caches against 
each other.  The major advantage of a common set of LRU lists is that
it gives us a basis for a balanced VM.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
