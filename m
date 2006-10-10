Subject: Re: ptrace and pfn mappings
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20061010034606.GJ15822@wotan.suse.de>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
	 <20061009140447.13840.20975.sendpatchset@linux.site>
	 <1160427785.7752.19.camel@localhost.localdomain>
	 <452AEC8B.2070008@yahoo.com.au>
	 <1160442987.32237.34.camel@localhost.localdomain>
	 <20061010022310.GC15822@wotan.suse.de>
	 <1160448466.32237.59.camel@localhost.localdomain>
	 <20061010025821.GE15822@wotan.suse.de>
	 <1160451656.32237.83.camel@localhost.localdomain>
	 <20061010034606.GJ15822@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 14:58:15 +1000
Message-Id: <1160456295.32237.99.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> Since we decided it would be better to make a new function or some arch
> specfic hooks rather than switch mm's in the kernel? ;)
> 
> No, I don't know. Your idea might be reasonable, but I really haven't
> thought about it much.

Another option is to take the PTE lock while doing the accesses for that
PFN... might work. We still need a temp kernel buffer but that would
sort-of do the trick.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
