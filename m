Date: Fri, 10 May 2002 10:55:45 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: page table entries
Message-ID: <20020510105545.A3297@redhat.com>
References: <Pine.GSO.4.10.10205101049310.14865-100000@mailhub.cdac.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.10.10205101049310.14865-100000@mailhub.cdac.ernet.in>; from sanket.rathi@cdac.ernet.in on Fri, May 10, 2002 at 11:00:52AM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sanket Rathi <sanket.rathi@cdac.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, May 10, 2002 at 11:00:52AM +0530, Sanket Rathi wrote:

> The problem is i am not able to understand that why the pgd_val, pmd_val
> and pte_val contain 0x63 in last two positions actually they are page
> address so their last 3 position(in hex) should be zero like in io
> address.

You're actually looking at a pte value, not just an address.  The low
12 bits in a pte's contents are not used for addressing but for pte
metadata.  In this case, those bits correspond to:

#define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |
_PAGE_DIRTY)

from linux/include/asm-i386/pgtable.h.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
