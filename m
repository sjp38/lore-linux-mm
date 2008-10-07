Date: Tue, 7 Oct 2008 13:31:32 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081007133132.69f69cc0@lxorguk.ukuu.org.uk>
In-Reply-To: <20081007112418.GC5126@localhost.localdomain>
References: <20081006132651.GG3180@one.firstfloor.org>
	<1223303879-5555-1-git-send-email-kirill@shutemov.name>
	<20081007195837.5A6B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081007112418.GC5126@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Honestly, I don't like that qemu specific feature insert into shmem core.
> > At least, this patch is too few comments.
> > Therefore, an develpper can't understand why SHM_MAP_HINT exist.
> > 
> > I think this patch description is too short and too poor.
> > I don't like increasing mysterious interface.
> 
> Sorry for it. I'll fix it in next patch version.

I also don't see the point of this interface. We have POSIX shared memory
objects in Linux which are much cleaner and neater. They support mmap()
and mmap supports address hints.

There seems to be no reason at all to add further hacks to the historical
ugly SYS5 interface.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
