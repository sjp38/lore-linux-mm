Date: Sun, 18 Apr 2004 08:52:19 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418155219.GA743@holomorphy.com>
References: <20040418093949.GY743@holomorphy.com> <Pine.LNX.4.44.0404181142290.12120-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0404181142290.12120-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 11:58:21AM +0100, Hugh Dickins wrote:
> mm and address are directly available in both mine and Andrea's (the
> difference between us is finding vma: mine needs find_vma in the anon
> case, on Andrea's it's directly available), shouldn't be any need to
> add in that ppc/ppc64 code.
> Hmm, maybe I didn't look hard enough at it, and could have just taken
> it out of ppc/ppc64, instead of moving it from generic; I'll go back
> and check on that sometime.
> I'm not surprised Russell's found he just needs mm rather than vma,
> I did try briefly yesterday to understand just what it is that vma
> gives to flush TLB.  Needs thorough research through all the arches,
> the ARM case is not necessarily representative.
> Wouldn't surprise me if it turns out vma necessary on some in the
> file-backed case, but on none in the anon case (would then cease
> to be a differentiator between anonmm and anon_vma if so).

I have to confess to not looking closely at the recent merge-oriented
code. Passing the things in when they're available will do it.


On Sun, Apr 18, 2004 at 11:58:21AM +0100, Hugh Dickins wrote:
> But I still think that we'd want to cut down on the intercpu TLB
> flushes for page_referenced, should batch them up to some extent.
> Russell may well be right that we're much too lazy about the
> referenced bit in 2.6, but that doesn't mean we now have to
> jump and get it exactly right all the time: the dirty bit is
> vital, the referenced bit never more than a hint.

I'm not foreseeing many effective algorithms for batching TLB flushes
there. Maybe something will get brewed up that surprises me.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
