Date: Thu, 24 Feb 2000 03:35:02 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: mmap/munmap semantics
Message-ID: <20000224033502.B6548@pcep-jamie.cern.ch>
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de> <14516.11124.729025.321352@dukat.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14516.11124.729025.321352@dukat.scot.redhat.com>; from Stephen C. Tweedie on Wed, Feb 23, 2000 at 06:48:20PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > - I need to "drop" a mapping sometimes without writing the contents
> >   back to disk - I cannot see a way to do this with linux currently.
> 
> The only way is to use Chuck Lever's madvise() patches:
> madvise(MADV_DONTNEED) is exactly what you need there.  It's not yet in
> Linus's 2.3 tree, but the API is pretty standard.

I don't think MADV_DONTNEED actually drops privately modified data does
it?  I thought it was merely a hint to the kernel that the data will not
be accessed again soon, so it can be paged out or, if unmodified,
dropped.  All the other MADV_* flags are access hints.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
