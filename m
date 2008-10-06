Subject: Re: [PATCH next 1/3] slub defrag: unpin writeback pages
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
References: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
Date: Mon, 06 Oct 2008 10:53:12 +0300
Message-Id: <1223279592.30581.4.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2008-10-05 at 03:25 +0100, Hugh Dickins wrote:
> A repetitive swapping load on powerpc G5 went progressively slower after
> nine hours: Inactive(file) was rising, as if inactive file pages pinned.
> Yes, slub defrag's kick_buffers() was forgetting to put_page() whenever
> it met a page already under writeback.
> 
> That PageWriteback test should be made while PageLocked in trigger_write(),
> just as it is in try_to_free_buffers() - if there are complex reasons why
> that's not actually necessary, I'd rather not have to think through them.
> A preliminary check before taking the lock?  No, it's not that important.
> 
> And trigger_write() must remember to unlock_page() in each of the cases
> where it doesn't reach the writepage().
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Looks good to me. I've applied the patch now but would really like an
ACK from Christoph/Andrew as well. Thanks again, Hugh!

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
