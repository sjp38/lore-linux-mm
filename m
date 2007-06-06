Subject: Re: [PATCH 3/4] mm: move_page_tables{,_up}
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <65dd6fd50706061206y558e7f90t3740424fae7bdc9c@mail.gmail.com>
References: <20070605150523.786600000@chello.nl>
	 <20070605151203.738393000@chello.nl>
	 <65dd6fd50706061206y558e7f90t3740424fae7bdc9c@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 06 Jun 2007 21:12:14 +0200
Message-Id: <1181157134.5676.28.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-06 at 12:06 -0700, Ollie Wild wrote:
> On 6/5/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > Provide functions for moving page tables upwards.
> 
> Now that we're initializing the temporary stack location to
> STACK_TOP_MAX, do we still need move_page_tables_up() for variable
> length argument support?  I originally added it into shift_arg_pages()
> to support 32-bit apps exec'ing 64-bit apps when we were using
> TASK_SIZE as our temporary location.
> 
> Maybe we should decouple this patch from the others and submit it as
> an enhancement to support memory defragmentation.

PA-RISC will still need it, right?

On the defrag thingy, I talked with Mel today, and neither of us can see
a usefull application of these functions to his defrag work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
