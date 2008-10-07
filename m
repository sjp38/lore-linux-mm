Date: Tue, 7 Oct 2008 15:14:20 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081007131420.GK20740@one.firstfloor.org>
References: <20081006132651.GG3180@one.firstfloor.org> <1223303879-5555-1-git-send-email-kirill@shutemov.name> <20081007195837.5A6B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081007112418.GC5126@localhost.localdomain> <20081007133132.69f69cc0@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081007133132.69f69cc0@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> I also don't see the point of this interface. We have POSIX shared memory
> objects in Linux which are much cleaner and neater. They support mmap()
> and mmap supports address hints.
> 
> There seems to be no reason at all to add further hacks to the historical
> ugly SYS5 interface.

Typically it's because some other parts of the interfaces that
cannot be easily changed (X shm would come to mind) need it.

He also needs it for the qemu syscall emulation. Even when he uses the compat
entry point shmat() will still only follow the personality.

-Andi
-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
