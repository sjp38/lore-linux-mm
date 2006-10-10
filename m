Subject: Re: faults and signals
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <452AF546.4000901@yahoo.com.au>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
	 <20061009140447.13840.20975.sendpatchset@linux.site>
	 <1160427785.7752.19.camel@localhost.localdomain>
	 <452AEC8B.2070008@yahoo.com.au>
	 <1160442685.32237.27.camel@localhost.localdomain>
	 <452AF546.4000901@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 11:58:30 +1000
Message-Id: <1160445510.32237.50.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> Yep, the flags field should be able to do that for you. Since we have
> the handle_mm_fault wrapper for machine faults, it isn't too hard to
> change the arguments: we should probably turn `write_access` into a
> flag so we don't have to push too many arguments onto the stack.
> 
> This way we can distinguish get_user_pages faults. And your
> architecture will have to switch over to using __handle_mm_fault, and
> distinguish kernel faults. Something like that?

Yes. Tho it's also fairly easy to just add an argument to the wrapper
and fix all archs... but yeah, I will play around.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
