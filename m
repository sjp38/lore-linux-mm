Date: Tue, 7 Aug 2001 18:13:11 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <20010807210803.C2476@thunk.org>
Message-ID: <Pine.LNX.4.33.0108071809590.1061-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Chris Mason <mason@suse.com>, Daniel Phillips <phillips@bonn-fries.net>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Theodore Tso wrote:
>
> mke2fs is a completely different case.  That's just a simple write
> throttling problem --- mke2fs simply is doing a lot of disk writes to
> a block device very quickly (zeroing out the inode table).

Well, the thing is, that some other loads seem to follow patterns that are
not entirely unlike this one.

> (We seem to have a habit of repeatedly breaking write throttling; it
> was broken for a while in 2.2, then it got fixed, then someone wanted
> to "fix" the VM, and they would break write throttling again... and
> again... and again....)

It really doesn't seem to have been write throttling per se - this
happened even without HIGHMEM, and the really broken write throttling was
the HIGHMEM case.

We would just happen to get into an unlucky situation where the buffer
allocation code would think that we didn't have enough memory, while the
VM layer was convinced that we _did_ have enough memory, and wouldn't
bother to free anything up. Admittedly, bad write throttling probably made
it easier to reach this stage, but I think the real problem was that we
had different parts of the system not quite agreeing to what was "enough
memory".

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
