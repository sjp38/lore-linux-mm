Date: Sun, 18 Apr 2004 09:47:02 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040417234702.GZ1815@krispykreme>
References: <20040417211506.C21974@flint.arm.linux.org.uk> <Pine.LNX.4.44.0404172311120.2124-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0404172311120.2124-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> I think you're quite likely right on all counts; and this may be why
> ppc and ppc64 have arranged their ptep_test_and_clear_young to flush TLB.

Yep thats the reason we do it.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
