Date: Sat, 4 Aug 2001 00:14:05 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108032045280.15155-200000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33.0108040012020.14842-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2001, Linus Torvalds wrote:

> For nicer interactive behaviour while flushing things out, the
> inode_fsync() thing should really use "write_locked_buffers()". That's a
> separate patch, though.

Mildly better interactive performance, but absolutely horrid io
throughput.  The system degrades to the point where blocks are getting
flushed to disk at ~2MB/s vs the 80MB/s its capable of.  Not instrumented
since I'm trying to actually relax.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
