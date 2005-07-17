Date: Sat, 16 Jul 2005 22:56:12 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050716205038.48c05e96.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0507162253020.28788@schroedinger.engr.sgi.com>
References: <20050715214700.GJ15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
 <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
 <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
 <20050715234402.GN15783@wotan.suse.de> <Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
 <20050716020141.GO15783@wotan.suse.de> <20050716163030.0147b6ba.pj@sgi.com>
 <Pine.LNX.4.62.0507161842090.26674@schroedinger.engr.sgi.com>
 <20050716205038.48c05e96.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: ak@suse.de, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jul 2005, Paul Jackson wrote:

> I'm missing something here.  Are you saying that just a change to
> libnuma would suffice to accomplish what you sought with this patch?

Its a quite significant change but yes of course you can do that if you 
really favor libnuma and IMHO want to make it difficult to maintain and to 
use.

> If that's the case, we don't need a kernel patch, right?

Sure.

> And despite Andi's urging us to only access these facilities via
> libnuma, there is no law to that affect that I know of.  At the least,
> you could present user level only code that accomplished the object
> of this patch set, with no kernel change.

Sure you can write a series of tools that accomplish the same.
 
> I don't think that is possible, short of gross hackery on /dev/mem.
> I think some sort of kernel change is required to enable one task to
> change the numa policy of another task.

Yes doing what I said to libnuma would require a significant rework of the 
APIs and the kernel libnuma stuff. Its easier to implement the whole thing 
using /proc, then no libraries would need to be modified, no tools need to 
be written. Just accept the patch that I posted, fix up whatever has to be 
fixed and we are done.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
