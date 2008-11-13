Date: Thu, 13 Nov 2008 15:09:32 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 0/7] cpu alloc stage 2
In-Reply-To: <Pine.LNX.4.64.0811130827450.19293@quilx.com>
Message-ID: <Pine.LNX.4.64.0811131507300.10624@quilx.com>
References: <20081105231634.133252042@quilx.com> <20081112175717.4a1fd679.sfr@canb.auug.org.au>
 <Pine.LNX.4.64.0811121406550.31606@quilx.com> <20081113103510.4a6a1d3a.sfr@canb.auug.org.au>
 <Pine.LNX.4.64.0811130827450.19293@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

I put a cpu_alloc_stage2 onto the git archive

git.kernel.org/pub/scm/linux/kernel/git/christoph/work.git cpu_alloc_stage2

Not sure if I should dare to merge it into the cpu_alloc branch. Its
pretty touchy work with some of the core components.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
