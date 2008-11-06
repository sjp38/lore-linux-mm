Date: Thu, 6 Nov 2008 10:27:16 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 5/7] x86_64: Support for cpu ops
In-Reply-To: <491310E1.1080002@sgi.com>
Message-ID: <Pine.LNX.4.64.0811061024070.6009@quilx.com>
References: <20081105231634.133252042@quilx.com> <20081105231649.108433550@quilx.com>
 <20081106071206.GH15731@elte.hu> <Pine.LNX.4.64.0811060907570.3595@quilx.com>
 <20081106151558.GB1644@elte.hu> <491310E1.1080002@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008, Mike Travis wrote:

> Sorry, this was on my plate but the 4096 cpus if far more critical to get
> released and available.  As soon as that's finally done, I can get back to
> the pda/zero-based changes.

You cannot solve your 4k issues without getting the zerobased stuff in
becaus otherwise the large pointer arrays in the core (page allocator and
slab allocator etc) are not removable. Without getting zerobased sorted
out you will produce a lot of hacks around subsystems that create pointer
arrays that would go away easily if you had the percpu aallocator.

I'd say getting the zero based stuff issues fixed is a prerequisie for
further work on 4k making sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
