Message-ID: <491310E1.1080002@sgi.com>
Date: Thu, 06 Nov 2008 07:44:33 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [patch 5/7] x86_64: Support for cpu ops
References: <20081105231634.133252042@quilx.com> <20081105231649.108433550@quilx.com> <20081106071206.GH15731@elte.hu> <Pine.LNX.4.64.0811060907570.3595@quilx.com> <20081106151558.GB1644@elte.hu>
In-Reply-To: <20081106151558.GB1644@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <cl@linux-foundation.org>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Christoph Lameter <cl@linux-foundation.org> wrote:
> 
>> On Thu, 6 Nov 2008, Ingo Molnar wrote:
>>
>>> hm, what happened to the rebase-PDA-to-percpu-area optimization 
>>> patches you guys were working on? I remember there was some 
>>> binutils flakiness - weird crashes and things like that. Did you 
>>> ever manage to stabilize it? It would be sad if only 32-bit could 
>>> take advantage of the optimized ops.
>> I thought that was in your tree? I saw a conflict in -next with the 
>> zero based stuff a couple of weeks ago. Mike is working on that 
>> AFAICT.
> 
> No, what's in tip/core/percpu is not the PDA patches:
> 
>  f8d90d9: percpu: zero based percpu build error on s390
>  cfcfdff: Merge branch 'linus' into core/percpu
>  d379497: Zero based percpu: infrastructure to rebase the per cpu area to zero
>  b3a0cb4: x86: extend percpu ops to 64 bit
> 
> But it's not actually utilized on x86. AFAICS you guys never came back 
> with working patches for that (tip/x86/percpu is empty currently), and 
> now i see something related on lkml on a separate track not Cc:-ed to 
> the x86 folks so i thought i'd ask whether more coordination is 
> desired here.
> 
> So ... what's the merge plan here? I like your fundamental idea, it's 
> a nice improvement in a couple of areas and i'd like to help out make 
> it happen. Also, the new per-cpu allocator would be nice for the 
> sparseirq code.
> 
> 	Ingo

Sorry, this was on my plate but the 4096 cpus if far more critical to get
released and available.  As soon as that's finally done, I can get back to
the pda/zero-based changes.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
