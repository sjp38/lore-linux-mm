Date: Tue, 11 Nov 2008 15:56:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/7] cpu alloc stage 2
Message-Id: <20081111155611.93b978df.akpm@linux-foundation.org>
In-Reply-To: <20081105231634.133252042@quilx.com>
References: <20081105231634.133252042@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, sfr@canb.auug.org.au, vegard.nossum@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 05 Nov 2008 17:16:34 -0600
Christoph Lameter <cl@linux-foundation.org> wrote:

> The second stage of the cpu_alloc patchset can be pulled from
> 
> git.kernel.org/pub/scm/linux/kernel/git/christoph/work.git cpu_alloc_stage2
> 
> Stage 2 includes the conversion of the page allocator
> and slub allocator to the use of the cpu allocator.
> 
> It also includes the core of the atomic vs. interrupt cpu ops and uses those
> for the vm statistics.

It all looks very nice to me.  It's a shame about the lack of any
commonality with local_t though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
