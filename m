Date: Sun, 24 Sep 2000 22:01:04 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000925040230.D10381@athlon.random>
Message-ID: <Pine.GSO.4.21.0009242151240.14096-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> On Sun, Sep 24, 2000 at 09:27:39PM -0400, Alexander Viro wrote:
> > So help testing the patches to them. Arrgh...
> 
> I think I'd better fix the bugs that I know about before testing patches that
> tries to remove the superblock_lock at this stage. I guess you should
> re-read the email from DaveM of two days ago.

Erm... Did you miss the fact that minixfs/sysvfs/UFS are choke-full of
fs-corrupting races? Patch for minixfs had been posted 3 times during the
last couple of weeks, each time with [CFT] in subject. So far - 0
(zero) responces. I'm way past the stage when I gave a damn - it works
here and if I will not receive any bug reports it will go to Linus on
Tuesday.

And no, that stuff has nothing to lock_super(). But unless people will
test the patches posted on l-k and fsdevel - too fscking bad, stuff _will_
break.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
