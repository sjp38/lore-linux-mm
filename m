Date: Wed, 6 Jun 2007 08:40:03 -0600
From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [parisc-linux] Re: [PATCH 4/4] mm: variable length argument
	support
Message-ID: <20070606144003.GD9722@colo.lackof.org>
References: <20070605150523.786600000@chello.nl> <20070605151203.790585000@chello.nl> <20070606013658.20bcbe2f.akpm@linux-foundation.org> <1181120061.7348.177.camel@twins> <20070606020651.19a89dca.akpm@linux-foundation.org> <1181121129.7348.181.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181121129.7348.181.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, linux-mm@kvack.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 06, 2007 at 11:12:09AM +0200, Peter Zijlstra wrote:
...
> > I think the same problem will happen on NOMMU && STACK_GROWS_UP.  There are
> > several new references to bprm->vma in there, not all inside CONFIG_MMU.
> 
> Right, which archs have that combo? I'll go gather cross compilers.

parisc only supports with MMU. I don't know who elses uses STACK_GROWS_UP.

hth,
grant

> 
> Perhaps I'd better create a flush_arg_page() function and stick that in
> the mmu/nommu section somewhere earlier on in that file. Patch in a few.
> 
> A related question; does anybody know of a no-MMU arch that uses
> fs/compat.c ? If there is such a beast, that would need some work.
> 
> _______________________________________________
> parisc-linux mailing list
> parisc-linux@lists.parisc-linux.org
> http://lists.parisc-linux.org/mailman/listinfo/parisc-linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
