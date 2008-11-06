Date: Thu, 6 Nov 2008 09:08:44 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 5/7] x86_64: Support for cpu ops
In-Reply-To: <20081106071206.GH15731@elte.hu>
Message-ID: <Pine.LNX.4.64.0811060907570.3595@quilx.com>
References: <20081105231634.133252042@quilx.com> <20081105231649.108433550@quilx.com>
 <20081106071206.GH15731@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008, Ingo Molnar wrote:

> hm, what happened to the rebase-PDA-to-percpu-area optimization
> patches you guys were working on? I remember there was some binutils
> flakiness - weird crashes and things like that. Did you ever manage to
> stabilize it? It would be sad if only 32-bit could take advantage of
> the optimized ops.

I thought that was in your tree? I saw a conflict in -next with the zero
based stuff a couple of weeks ago. Mike is working on that AFAICT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
