Received: from kanga.kvack.org (root@kanga.kvack.org [205.189.68.98])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA30866
	for <linux-mm@kvack.org>; Fri, 15 Jan 1999 01:07:53 -0500
Date: Fri, 15 Jan 1999 01:07:33 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Why don't shared anonymous mappings work?
In-Reply-To: <199901140307.UAA25835@nyx10.nyx.net>
Message-ID: <Pine.LNX.3.95.990115005029.16568D-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Colin Plumb <colin@nyx.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 1999, Colin Plumb wrote:

> Um, okay, how about a more plausible scenario.  Processes 1 and 2
> share a page X.  Process 1 forks.
> 
> Doesn't this lead to the hairy Mach-like situation?

Nope, the new process inherits the mapping with the shared attribute
intact.

> Um, I think you fail to understand.  I was talking about a linked list
> *without* allocating extra space.  The idea is that I don't know of a
> processor that requires more than 2 bits (M68K) to mark a PTE as invalid;
> the user gets the rest.  Currently the user bits in the invalid PTE
> encodings point to swap pages.  You could steal one bit and point to
> either a word in memory or a swap page.

Ooops, brain fart (sometimes you read, but the meaning just isn't
absorbed).  I think assuming that you can get 30 bits out of a pte on a 32
bit platform to use as a pointer is pushing things, though (and you do
need all the bits: mremap allows users to move shared pages to different
offset within a page table).  Under the scheme I'm planning on
implementing, this is a non issue: all pages are tied to an inode. 
Alternatively, we could pull i_mmap & co out of struct inode and make a
vmstore (or whatever) object as I believe Eric suggested. 

		-ben

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
