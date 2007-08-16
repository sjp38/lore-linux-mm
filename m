Date: Thu, 16 Aug 2007 14:29:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v9
In-Reply-To: <20070816074525.065850000@chello.nl>
Message-ID: <Pine.LNX.4.64.0708161424010.18861@schroedinger.engr.sgi.com>
References: <20070816074525.065850000@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Is there any way to make the global limits on which the dirty rate 
calculations are based cpuset specific?

A process is part of a cpuset and that cpuset has only a fraction of 
memory of the whole system. 

And only a fraction of that fraction can be dirtied. We do not currently 
enforce such limits which can cause the amount of dirty pages in 
cpusets to become excessively high. I have posted several patchsets that 
deal with that issue. See http://lkml.org/lkml/2007/1/16/5

It seems that limiting dirty pages in cpusets may be much easier to 
realize in the context of this patchset. The tracking of the dirty pages 
per node is not necessary if one would calculate the maximum amount of 
dirtyable pages in a cpuset and use that as a base, right?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
