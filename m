Date: Mon, 12 Jun 2000 15:16:59 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: O_SYNC patches for 2.4.0-test1-ac11
Message-ID: <20000612151659.C5704@pcep-jamie.cern.ch>
References: <20000609223632.E2621@redhat.com> <m3ya4ettbk.fsf@otr.mynet.cygnus.com> <20000609225802.I2621@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000609225802.I2621@redhat.com>; from sct@redhat.com on Fri, Jun 09, 2000 at 10:58:02PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ulrich Drepper <drepper@cygnus.com>, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Theodore Ts'o <tytso@valinux.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> No.  If we do posix_fallocate(), then there are only two choices:
> we either pre-zero the file contents (in which case we are as well
> doing it from user space), or we record in the inode that the file
> isn't pre-zeroed and so optimise things.

3rd choice: preallocate space with room for interleaved indirection
blocks.  You don't need to record anything in the inode: it's the
indirection blocks that get changed as you fill up the file.  And
they're in exactly the right place.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
