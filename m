Message-ID: <44BCFA4D.9030300@mbligh.org>
Date: Tue, 18 Jul 2006 11:12:13 -0400
From: "Martin J. Bligh" <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: inactive-clean list
References: <1153167857.31891.78.camel@lappy>  <Pine.LNX.4.64.0607172035140.28956@schroedinger.engr.sgi.com> <1153224998.2041.15.camel@lappy> <Pine.LNX.4.64.0607180557440.30245@schroedinger.engr.sgi.com> <44BCE86A.4030602@mbligh.org> <Pine.LNX.4.64.0607180657160.30887@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0607180657160.30887@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 18 Jul 2006, Martin J. Bligh wrote:
> 
> 
>>Someone remind me why we can't remove the memlocked pages from the LRU
>>again? Apart from needing a refcount of how many times they're memlocked
>>(or we just shove them back whenever they're unlocked, and let it fall
>>out again when we walk the list, but that doesn't fix the accounting
>>problem).
> 
> 
> We simply do not unmap memlocked pages (see try_to_unmap). And therefore
> they are not reclaimable.

The point is that they're still going to be included in your counts.


> On Tue, 18 Jul 2006, Andrew Morton wrote:
>>> Christoph Lameter <clameter@sgi.com> wrote:
>>>> > What other types of non freeable pages could exist?
>>> 
>>> PageWriteback() pages (potentially all of memory)
> 
> Doesnt write throttling take care of that?
> 
>>> Pinned pages (various transient conditions, mainly get_user_pages())
> 
> Hmm....
> 
>>> Some pages whose buffers are attached to an ext3 journal.
> 
> These are just pinned by an increased refcount right?
> 
>>> Possibly NFS unstable pages.
> 
> These are tracked by NR_NFS_UNSTABLE.
> 
> Maybe we need a NR_UNSTABLE that includes pinned pages?

The point of what we decided on Sunday was that we want to count the
pages that we KNOW are easy to free. So all of these should be
taken out of the count before we take it.

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
