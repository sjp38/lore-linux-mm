Date: Sat, 14 Oct 2000 01:26:48 -0700
Message-Id: <200010140826.BAA19023@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.10.10010131841120.962-100000@penguin.transmeta.com>
	(message from Linus Torvalds on Fri, 13 Oct 2000 18:43:47 -0700 (PDT))
Subject: Re: [RFC] atomic pte updates and pae changes, take 2
References: <Pine.LNX.4.10.10010131841120.962-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: bcrl@redhat.com, mingo@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

   I dislike the "__HAVE_ARCH_xxx" approach, and considering that most
   architectures will probably want to do something specific anyway I
   wonder if we should get rid of that and just make architectures
   have their own code.

Most software-based TLB refill systems could (and sparc64 will) make
all ref/mod bit updates occur in the kernel software fault path so
that none of this special synchronization is necessary.

In such cases it might be nice to have a generic version that all such
ports can share by just not defining __HAVE_ARCH_xxx.

Sure it's a bit ugly, but it does allow code sharing, so it probably
at least deserves a chance :-)

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
