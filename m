Date: Tue, 8 May 2007 16:05:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] stub MADV_FREE implementation
Message-Id: <20070508160547.e1576146.akpm@linux-foundation.org>
In-Reply-To: <463FF3D3.9060007@redhat.com>
References: <4632D0EF.9050701@redhat.com>
	<463B108C.10602@yahoo.com.au>
	<463B598B.80200@redhat.com>
	<463BC62C.3060605@yahoo.com.au>
	<463FF3D3.9060007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ulrich Drepper <drepper@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jakub Jelinek <jakub@redhat.com>, Dave Jones <davej@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 07 May 2007 23:51:47 -0400
Rik van Riel <riel@redhat.com> wrote:

> Until we have better performance numbers on the lazy reclaim path,
> we can just alias MADV_FREE to MADV_DONTNEED with this trivial
> patch.
> 
> This way glibc can go ahead with the optimization on their side
> and we can figure out the kernel side later.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Could someone please explain what is going on here?


And has Ulrich indicated that glibc would indeed go out ahead of
the kernel in this fashion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
