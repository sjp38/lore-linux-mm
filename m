Date: Wed, 28 Jun 2006 21:27:54 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 0/6] mm: tracking dirty pages -v14
In-Reply-To: <20060628201702.8792.69638.sendpatchset@lappy>
Message-ID: <Pine.LNX.4.64.0606282126140.32141@blonde.wat.veritas.com>
References: <20060628201702.8792.69638.sendpatchset@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jun 2006, Peter Zijlstra wrote:
> 
> Hopefully the last version (again!).
> 
> Hugh really didn't like my vma_wants_writenotify() flags, so I took
> them out again.
> 
> Also added another patch to the end that corrects the do_wp_page()
> COWing of anonymous pages.

Thanks for the retry, Peter: they look good to me now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
