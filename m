Date: Mon, 25 Sep 2000 14:47:15 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925144715.D2615@redhat.com>
References: <20000925033128.A10381@athlon.random> <Pine.GSO.4.21.0009242122520.14096-100000@weyl.math.psu.edu> <20000925040230.D10381@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925040230.D10381@athlon.random>; from andrea@suse.de on Mon, Sep 25, 2000 at 04:02:30AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alexander Viro <viro@math.psu.edu>, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 04:02:30AM +0200, Andrea Arcangeli wrote:
> On Sun, Sep 24, 2000 at 09:27:39PM -0400, Alexander Viro wrote:
> > So help testing the patches to them. Arrgh...
> 
> I think I'd better fix the bugs that I know about before testing patches that
> tries to remove the superblock_lock at this stage.

Right.  If we're introducing new deadlock possibilities, then sure we
can fix the obvious cases in ext2, but it will be next to impossible
to do a thorough audit of all of the other filesystems.  Adding in the
new shrink_icache loop into the VFS just feels too dangerous right
now.

Of course, that doesn't mean we shouldn't remove the excessive
superblock locking from ext2 --- rather, it is simply more robust to
keep the two issues separate.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
