From: Christoph Rohland <cr@sap.com>
Subject: Re: [Patch] deadlock on write in tmpfs
References: <m3hez5ci6p.fsf@linux.local> <20010501173210.S26638@redhat.com>
Date: 02 May 2001 14:00:53 +0200
In-Reply-To: <20010501173210.S26638@redhat.com>
Message-ID: <m3hez4arka.fsf@linux.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Stephen,

On Tue, 1 May 2001, Stephen C. Tweedie wrote:
> If the locking is for a completely different reason, then a
> different semaphore is quite appropriate.  In this case you're
> trying to lock the shm internal info structures, which is quite
> different from the sort of inode locking which the VFS tries to do
> itself, so the new semaphore appears quite clean --- and definitely
> needed.

It's not the addition to the inode semaphore I do care about, but the
addition to the spin lock which protects also the shmem internals. But
you are probably right: It only protects the onthefly pages between
page cache and swap cache.

Greetings
		Christoph


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
