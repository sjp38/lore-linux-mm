Date: Thu, 13 Nov 2008 08:28:24 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 0/7] cpu alloc stage 2
In-Reply-To: <20081113103510.4a6a1d3a.sfr@canb.auug.org.au>
Message-ID: <Pine.LNX.4.64.0811130827450.19293@quilx.com>
References: <20081105231634.133252042@quilx.com> <20081112175717.4a1fd679.sfr@canb.auug.org.au>
 <Pine.LNX.4.64.0811121406550.31606@quilx.com> <20081113103510.4a6a1d3a.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Nov 2008, Stephen Rothwell wrote:

> > I will push out a new patchset and tree in the next hour or so for
> > you to merge into linux-next.
>
> Why not just add these to the cpu_alloc tree I already have?

What happens if there are problems with the next stage? I want to make
sure that at least the basis is merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
