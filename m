Message-ID: <393E8499.A7FB2DC9@timpanogas.com>
Date: Wed, 07 Jun 2000 11:21:29 -0600
From: "Jeff V. Merkey" <jmerkey@timpanogas.com>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva> <20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica> <20000607163519.S30951@redhat.com> <393E8204.D7AAACC5@timpanogas.com> <20000607181405.W30951@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Quintela Carreira Juan J." <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Stephen,

I will go look at it.

Thanks 

:-) :-) :-) :-)

Jeff

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Wed, Jun 07, 2000 at 11:10:28AM -0600, Jeff V. Merkey wrote:
> >
> > When will the journalling subsystem you are working on be available, and
> > where can I get it to start integration work.  It sounds like you will
> > be "bundling"  associated LRU meta-data blocks in the buffer cache for
> > journal commits?  What Alan described to me sounds fairly decent.  I am
> > wondering when you will have this posted so the rest of us can
> > instrument your journalling code into our FS's.
> 
> Have a look at the fs/jfs directory in ext3 if you want to see
> what I've been implementing.
> 
> Cheers,
>  Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
