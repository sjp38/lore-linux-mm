From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14319.31624.187625.428832@dukat.scot.redhat.com>
Date: Mon, 27 Sep 1999 15:13:28 +0100 (BST)
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909251232540.22660-100000@imperial.edgeglobal.com>
References: <Pine.LNX.4.10.9909251639140.1083-100000@laser.random>
	<Pine.LNX.4.10.9909251232540.22660-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 25 Sep 1999 12:50:57 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> Is their any way to do cooperative locking kernel side between two
> memory regions? If one is being access you can't physically access the
> other. I just want to process to sleep not kill it if it attempts
> this.

Sure.  You can always use a semaphore or spinlock to do cooperative
locking.  Physically preventing the access is what is expensive (far,
far, far too expensive to be worthwhile doing it frequently if your
driver requires that).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
