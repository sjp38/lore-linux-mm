Subject: Re: [patch 17/20] non-reclaimable mlocked pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20071219095307.683978b0@cuia.boston.redhat.com>
References: <20071218211539.250334036@redhat.com>
	 <20071218211550.186819416@redhat.com>
	 <200712191156.48507.nickpiggin@yahoo.com.au>
	 <20071219084534.4fee8718@bree.surriel.com> <1198074247.6484.17.camel@twins>
	 <20071219095307.683978b0@cuia.boston.redhat.com>
Content-Type: text/plain
Date: Wed, 19 Dec 2007 11:08:38 -0500
Message-Id: <1198080519.5333.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-12-19 at 09:53 -0500, Rik van Riel wrote:
> On Wed, 19 Dec 2007 15:24:07 +0100
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > I thought Lee had patches that moved pages with long rmap chains (both
> > anon and file) out onto the non-reclaim list, for those a slow
> > background scan does make sense.
> 
> I suspect we won't be needing that code.  The SEQ replacement for
> swap backed pages might reduce the number of pages that need to
> be scanned to a reasonable number.
> 
> Remember, steady states are not a big problem with the current VM.
> It's the sudden burst of scanning that happens when the VM decides
> that it should start swapping (and every anonymous page is referenced)
> that kills large systems.

Yes, I still have the patch [for long anon_vma lists--not for
excessively mapped file, yet] and I'm keeping it up to date and tested.
I do see softlockups on the anon_vma and i_mmap_locks under stress, even
with the reader/writer lock patches.  I'll be trying the workloads on
Rik's latest patches to see if they address these lockups.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
