Date: Sun, 7 Jul 2002 17:38:27 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: vm lock contention reduction
Message-ID: <20020708003827.GC25360@holomorphy.com>
References: <Pine.LNX.4.44.0207042237130.7465-100000@home.transmeta.com> <Pine.LNX.4.44.0207042257210.7465-100000@home.transmeta.com> <3D253DC9.545865D4@zip.com.au> <20020705073315.GU1227@dualathlon.random> <3D27AC81.FC72D08F@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D27AC81.FC72D08F@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, Jul 06, 2002 at 07:50:41PM -0700, Andrew Morton wrote:
> Any time you have one of these pages in use, the process gets
> pinned onto the current CPU. If we run out of per-cpu kmaps,
> just fall back to traditional kmap().

This is not particularly difficult, it only requires a depth counter
and a saved cpumask for when it becomes unpinned again.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
