Date: Wed, 9 May 2007 17:38:46 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
In-Reply-To: <463B598B.80200@redhat.com>
Message-ID: <Pine.LNX.4.64.0705091724500.25202@blonde.wat.veritas.com>
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au>
 <463B598B.80200@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Ulrich Drepper wrote:
> 
> I don't want to judge the numbers since I cannot but I want to make an
> observations: even if in the SMP case MADV_FREE turns out to not be a
> bigger boost then there is still the UP case to keep in mind where Rik
> measured a significant speed-up.  As long as the SMP case isn't hurt
> this is reaosn enough to use the patch.  With more and more cores on one
> processor SMP systems are pushed evermore to the high-end side.  You'll
> find many installations which today use SMP will be happy enough with
> many-core UP machines.

Just remembered this mail from a few days ago, and how puzzled I'd been
by your last sentence or two: I seem to be reading it in the wrong way,
and don't understand why users of SMP kernels will be moving to UP?

UP in the sense of one processor but many cores?  But that still needs
an SMP kernel to use all those cores.  Or you're thinking of growing
virtualization?  Would you please explain further?

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
