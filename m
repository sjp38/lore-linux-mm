Date: Wed, 02 Oct 2002 17:48:01 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH] Snapshot of shared page tables
Message-ID: <183710000.1033598881@baldur.austin.ibm.com>
In-Reply-To: <15771.30104.815144.546550@argo.ozlabs.ibm.com>
References: <45850000.1033570655@baldur.austin.ibm.com>
 <15771.30104.815144.546550@argo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--On Thursday, October 03, 2002 08:39:20 +1000 Paul Mackerras
<paulus@samba.org> wrote:

> Interesting.  I notice that you are using the _PAGE_RW bit in the
> PMDs.  Are you relying on the hardware to do anything with that bit,
> or is it only used by software?
> 
> (If you are relying on the hardware to do something different when
> _PAGE_RW is clear in the PMD, then your approach isn't portable.)

Yes, I am relying on the hardware.  I was under the impression that it was
pretty much universal that making the pmd read-only would make the hardware
treat all ptes under it as read-only.  This came out of a discussion on
lkml last winter where this assertion was made.

Do you know of a page table-based architecture that doesn't have and honor
read-only protections at the pmd level?

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
