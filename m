Date: Tue, 7 Oct 2008 17:54:12 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081007175412.0d88da30@lxorguk.ukuu.org.uk>
In-Reply-To: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue,  7 Oct 2008 19:15:17 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> If SHM_MAP_NOT_FIXED specified and shmaddr is not NULL, then the kernel takes
> shmaddr as a hint about where to place the mapping. The address of the mapping
> is returned as the result of the call.
> 
> It's similar to mmap() without MAP_FIXED.

NAK

This is a pointless API extension tacked onto a historic interface that
isn't well designed.

Use shm_open, and mmap and you get the functionality required using
modern posix interfaces with *NO* Linux extensions involved.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
