Received: from peculier ([10.10.188.58]) (1188 bytes) by megami.veritas.com
    via sendmail with P:esmtp/R:smart_host/T:smtp
    (sender: <hugh@veritas.com>) id <m1BFBWx-0000kCC@megami.veritas.com> for
    <linux-mm@kvack.org>; Sun, 18 Apr 2004 05:36:15 -0700 (PDT)
    (Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Sun, 18 Apr 2004 13:36:11 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
In-Reply-To: <20040418122344.A11293@flint.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.44.0404181331240.20000-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 18 Apr 2004, Russell King wrote:
> 
> So, I think we definitely need the flush there.  The available data
> so far from Marc appears to confirm this, and the theory surrounding
> ASID-based MMUs (which are coming on ARM) also require it.

I agree that we need to flush TLB more, that if we keep on ignoring a
hint forever then things go awry.  I disagree that it needs to be done
so immediately, in the young/referenced/accessed case.  But go ahead,
we can always optimize some of it out later on.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
