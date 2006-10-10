Subject: Re: ptrace and pfn mappings
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20061010030344.GF15822@wotan.suse.de>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
	 <20061009140447.13840.20975.sendpatchset@linux.site>
	 <1160427785.7752.19.camel@localhost.localdomain>
	 <452AEC8B.2070008@yahoo.com.au>
	 <1160442987.32237.34.camel@localhost.localdomain>
	 <20061010022310.GC15822@wotan.suse.de>
	 <1160448466.32237.59.camel@localhost.localdomain>
	 <1160448968.32237.68.camel@localhost.localdomain>
	 <20061010030344.GF15822@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 13:42:55 +1000
Message-Id: <1160451775.32237.86.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> Hold your per-object lock? I'm not talking about using mmap_sem for
> migration, but the per-object lock in access_process_vm. I thought
> this prevented migration?

As I said in my previous mail. access_process_vm() is a generic function
called by ptrace, it has 0 knowledge of the internal locking scheme of
a driver providing a nopage/nopfn for a vma.

> OK, just do one pfn at a time. For ptrace that is fine. access_process_vm
> already copies from source into kernel buffer, then kernel buffer into
> target.

Even one pfn at a time ... the only way would be if we also took the PTE
lock during the copy in fact. That's the only lock that would provide
that same guarantees as an access I think.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
