From: Paul Mackerras <paulus@samba.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15771.30104.815144.546550@argo.ozlabs.ibm.com>
Date: Thu, 3 Oct 2002 08:39:20 +1000 (EST)
Subject: Re: [PATCH] Snapshot of shared page tables
In-Reply-To: <45850000.1033570655@baldur.austin.ibm.com>
References: <45850000.1033570655@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dave McCracken writes:

> Ok, here it is.  This patch works for my simple tests, both under UP and
> SMP, including under memory pressure.  I'd appreciate anyone who'd like to
> take it and beat on it.  Please let me know of any problems you find.

Interesting.  I notice that you are using the _PAGE_RW bit in the
PMDs.  Are you relying on the hardware to do anything with that bit,
or is it only used by software?

(If you are relying on the hardware to do something different when
_PAGE_RW is clear in the PMD, then your approach isn't portable.)

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
