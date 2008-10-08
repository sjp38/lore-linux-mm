Date: Wed, 8 Oct 2008 13:02:43 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081008110243.GN7971@one.firstfloor.org>
References: <20081007211038.GQ20740@one.firstfloor.org> <20081008000518.13f48462@lxorguk.ukuu.org.uk> <20081007232059.GU20740@one.firstfloor.org> <20081008004030.7a0e9915@lxorguk.ukuu.org.uk> <20081007235737.GD7971@one.firstfloor.org> <20081008093424.4e88a3c2@lxorguk.ukuu.org.uk> <20081008084350.GI7971@one.firstfloor.org> <20081008095851.01790b6a@lxorguk.ukuu.org.uk> <20081008091112.GK7971@one.firstfloor.org> <20081008112037.6fa37c0b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20081008112037.6fa37c0b@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 08, 2008 at 11:20:37AM +0100, Alan Cox wrote:
> > That is racy when multi threaded because shmat() doesn't replace, so you 
> > would need to munmap() inbetween and someone else could steal the area
> > then. Yes you could stick a loop around it. It could livelock.
> > No, it's not a good interface I would advocate.
> 
> You could just use pthread mutexes in your application. The role of the

malloc() can call mmap, so that would require putting a mutex around
each malloc(). Good luck finding them all.

> kernel is not to provide nappies for people who think programming is too
> hard but to provide services that can be used to build applications.

Outsourcing kernel locking to user space is not the way to go.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
