Date: Mon, 2 Oct 2000 14:16:15 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010021658040.1067-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010021414330.826-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 2 Oct 2000, Rik van Riel wrote:
>
> Linus, I remember you saying some time ago that you would
> like to keep the buffer heads on a page around so we'd
> have them at the point where we need to swap out again.

Only if it actually simplifies the VM and FS code noticeably.

Right now the VFS code already has all the complexity to handle
re-creating the buffer heads, so there's nothing to be gained from wasting
memory on them.

But we could make it an implementation decision to _always_ have the
buffer heads hanging around, and simplify (and possibly speed up) the code
by having that rule. It's not the case now, though.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
