Date: Sun, 10 Oct 1999 12:12:24 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: execve-question
In-Reply-To: <3800B13E.655140FE@colorfullife.com>
Message-ID: <Pine.GSO.4.10.9910101207500.16317-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 10 Oct 1999, Manfred Spraul wrote:

> what happens / should happen if I call execve() in a multi-threaded
> application?
> 
> I don't see that the mm structure is copied, and obviously noone
> acquires the mm->mmap_sem.

Check fs/exec.c::exec_mmap(). mmap_sem is _not_ needed here. We are not
copying the mm - we are creating new one (exec drops all mappings). For
$DEITY sake, stop applying band-aids.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
