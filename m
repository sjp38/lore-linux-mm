Date: Fri, 15 Oct 1999 17:44:01 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
In-Reply-To: <3807B5BA.151F676B@colorfullife.com>
Message-ID: <Pine.LNX.4.10.9910151740150.928-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Sat, 16 Oct 1999, Manfred Spraul wrote:
> 
> What about shm? vma->vm_file is NULL, this would oops.

Well, considering that shm_swapout() currently looks like this:

	static int shm_swapout(struct vm_area_struct * vma, struct page * page)
	{ 
	        return 0;
	}

I don't think the SHM case is all that problematic: we could easily just
have a dummy vma->vm_file there. In fact, it probably should do so anyway:
the SHM code _really_ does not need the private member.

There are strong arguments for saying that if the thing you're mapping
actually _needs_ the vma in order to swap out, then the thing is broken.
SHM certainly used to be horribly broken in this area, but that's no
longer true.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
