Subject: Re: [patch 4/5] mm: add vm_insert_pfn helpler
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20061009140447.13840.20975.sendpatchset@linux.site>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
	 <20061009140447.13840.20975.sendpatchset@linux.site>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 07:03:05 +1000
Message-Id: <1160427785.7752.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> +	vma->vm_flags |= VM_PFNMAP;

I wouldn't do that here. I would keep that to the caller (and set it
before setting the PTE along with a wmb maybe to make sure it's visible
before the PTE no ?)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
