Date: Wed, 27 Sep 2000 05:22:35 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [CFT][PATCH] ext2 directories in pagecache
In-Reply-To: <Pine.LNX.4.21.0009270931400.993-100000@elte.hu>
Message-ID: <Pine.GSO.4.21.0009270455310.24641-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marko Kreen <marko@l-t.ee>, Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 27 Sep 2000, Ingo Molnar wrote:

> 
> On Wed, 27 Sep 2000, Marko Kreen wrote:
> 
> > > Why?
> > > 
> > > > +                               } else if (de->name[2])
> > > 
> > Sorry, I had a hard day and I should have gone to sleep already...
> 
> hey, you made Alexander notice an endianness bug so it was ok :-)

Definitely. Usually "it looks fishy" feeling should be trusted - if code
is non-obvious it's more likely to contain bugs.

How it was? "The goal is to write clear code, not clever code". And right
now dir.c in the patch is not clear enough - better than the corresponding
code in the tree (esp. in ext2_readdir()), but still needs cleaning up.

ObFsck: router in the $ORKPLACE apparently deciding that it's a good time
to shit itself and external SCSI on one of the home boxen joining the
fun. Sheesh...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
