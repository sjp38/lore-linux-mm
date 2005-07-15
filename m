Date: Fri, 15 Jul 2005 14:04:37 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process
 through /proc/<pid>/numa_policy
Message-Id: <20050715140437.7399921f.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
	<Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
	<20050714230501.4a9df11e.pj@sgi.com>
	<Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> I think the syscall interface is plainly wrong for monitoring and managing 
> a process.

Well ... actually I'd have to agree with that.  I chose a filesys
interface for cpusets for similar reasons.

However in this case, the added functionality seems so close to
mbind/mempolicy that one has to at least give consideration to
remaining consistent with that style of interface.

These questions of interface style (filesys or syscall) probably don't
matter, however. at least not yet.  First we need to make sense of
the larger issues that Ken and Andi raise, of whether this is a good
thing to do.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
