From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [patch 3/4] spufs: convert nopfn to fault
Date: Fri, 2 May 2008 14:06:38 +1000
References: <20080502031903.GD11844@wotan.suse.de> <20080502032214.GG11844@wotan.suse.de>
In-Reply-To: <20080502032214.GG11844@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200805021406.38980.jk@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

Hi Nick,

> -static unsigned long spufs_mem_mmap_nopfn(struct vm_area_struct
> *vma, -					  unsigned long address)

Aside from the > 80 character lines, all is OK here.

Acked-by: Jeremy Kerr <jk@ozlabs.org>

Cheers,


Jeremy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
