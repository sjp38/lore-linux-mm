Date: Sat, 16 Jul 2005 20:50:38 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process
 through /proc/<pid>/numa_policy
Message-Id: <20050716205038.48c05e96.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507161842090.26674@schroedinger.engr.sgi.com>
References: <20050715214700.GJ15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
	<20050715220753.GK15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
	<20050715223756.GL15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
	<20050715225635.GM15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
	<20050715234402.GN15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
	<20050716020141.GO15783@wotan.suse.de>
	<20050716163030.0147b6ba.pj@sgi.com>
	<Pine.LNX.4.62.0507161842090.26674@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: ak@suse.de, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Correct. We could implement the changing of policies via an extension
> of the existing libnuma. That could be easily done as far as I can
> tell. If that is done then the patch that I proposed is no longer
> necessary. But then libnuma needs to also be extended to
> 
> 1. Allow the discovery of the memory policies of each vma for each
> process

I'm missing something here.  Are you saying that just a change to
libnuma would suffice to accomplish what you sought with this patch?

If that's the case, we don't need a kernel patch, right?

And despite Andi's urging us to only access these facilities via
libnuma, there is no law to that affect that I know of.  At the least,
you could present user level only code that accomplished the object
of this patch set, with no kernel change.

I don't think that is possible, short of gross hackery on /dev/mem.
I think some sort of kernel change is required to enable one task to
change the numa policy of another task.

What the heck, over ??

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
