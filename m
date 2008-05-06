From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [patch 3/4] spufs: convert nopfn to fault
Date: Tue, 6 May 2008 13:01:26 +1000
References: <20080502031903.GD11844@wotan.suse.de> <200805021943.54638.jk@ozlabs.org> <20080503054135.GA15552@wotan.suse.de>
In-Reply-To: <20080503054135.GA15552@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200805061301.26791.jk@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

Hi Nick,

> Hmm, in spufs_mem_mmap_fault, vm_insert_pfn should just take
> address (corrected for 64K), rather than the uncorrected address I
> gave it...

Yep, using the 'address' var for vm_insert_pfn fixes the problem for me.

Cheers,


Jeremy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
