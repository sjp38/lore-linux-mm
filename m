Date: Sun, 17 Jul 2005 00:22:41 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process
 through /proc/<pid>/numa_policy
Message-Id: <20050717002241.3224f104.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507162253020.28788@schroedinger.engr.sgi.com>
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
	<20050716205038.48c05e96.pj@sgi.com>
	<Pine.LNX.4.62.0507162253020.28788@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: ak@suse.de, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph, responding to pj:
> > I'm missing something here.  Are you saying that just a change to
> > libnuma would suffice to accomplish what you sought with this patch?
> 
> Its a quite significant change but yes of course you can do that ...

I am totally stumped.  I have no idea how what you have in mind.

The mbind, set_mempolicy and get_mempolicy system calls plainly and
simply apply only to the current task, and it would take changes in
kernel code and the system call API to change that fact in any
sensible way.

You've dropped one hint: its a quite significant change.

If you have the patience, could you drop a couple more hints on how
to do this (make this change by just changing libnuma)?  Perhaps with
a little more technical meat on their bones?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
