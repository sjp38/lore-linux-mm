Date: Mon, 25 Sep 2000 04:02:30 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925040230.D10381@athlon.random>
References: <20000925033128.A10381@athlon.random> <Pine.GSO.4.21.0009242122520.14096-100000@weyl.math.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.21.0009242122520.14096-100000@weyl.math.psu.edu>; from viro@math.psu.edu on Sun, Sep 24, 2000 at 09:27:39PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 24, 2000 at 09:27:39PM -0400, Alexander Viro wrote:
> So help testing the patches to them. Arrgh...

I think I'd better fix the bugs that I know about before testing patches that
tries to remove the superblock_lock at this stage. I guess you should
re-read the email from DaveM of two days ago.

Then I've a problem: I've no idea how could I test
adfs/affs/efs/hfs/hpfs/qnx4/sysv/udf.  If you send me by email or point out the
URL where I can find the source of the mkfs for all the above fs I will try to
add the tests in the regression test suite as soon as time permits so the
computer will do that job for me (that will be useful regardless of the
super-lock issue).

(if the mkfses are in common packages like mkfs.minix and mkfs.bfs no need to
send them of course)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
