Date: Tue, 22 Apr 2003 13:34:46 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <20030422165746.GK23320@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0304221324380.24424-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2003, Andrea Arcangeli wrote:

> could we focus and solve the remap_file_pages current breakage first?

truncate always used to be such a PITA in the VM. And so few code depends
on it doing the right thing to vmas. Which i claim to not be the right
thing at all.

is anything forcing us to fixing up mappings during a truncate? What we
need is just for the FS to recognize pages behind end-of-inode to still
potentially exist after truncation, if those areas were mapped before the
truncation. Apps that do not keep uptodate with truncaters can get
out-of-date data anyway, via read()/write() anyway. Are there good
arguments to be this strict across truncate()? We sure could make it safe
even thought it's not safe currently.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
