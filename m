Date: Thu, 10 Mar 2005 12:54:48 -0800
From: Paul Jackson <pj@engr.sgi.com>
Subject: Re: [PATCH] 0/2 Buddy allocator with placement policy (Version 9) +
 prezeroing (Version 4)
Message-Id: <20050310125448.5b52dcba.pj@engr.sgi.com>
In-Reply-To: <1110485835.24355.1.camel@localhost>
References: <20050307193938.0935EE594@skynet.csn.ul.ie>
	<1110239966.6446.66.camel@localhost>
	<Pine.LNX.4.58.0503101421260.2105@skynet>
	<20050310092201.37bae9ba.pj@engr.sgi.com>
	<1110478613.16432.36.camel@localhost>
	<20050310121124.488cb7c5.pj@engr.sgi.com>
	<1110485835.24355.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave wrote:
> Shouldn't a particular task know what the policy should be when it is
> launched? 

No ... but not necessarily because it isn't known yet, but rather also
because it might be imposed earlier in the job creation, before the
actual task hierarchy is manifest.  This point goes to the heart of one
of the motivations for cpusets themselves.

On a big system, one might have OpenMP threads inside MPI tasks inside
jobs being managed by a batch manager, running on a subset of the
system.  The system admins may need to impose these policy decisions
from the outside, and not uniformly across the entire batch managed
arena.  The cpuset becomes the named object, to which such attributes
accrue, to take affect on whatever threads, tasks, or jobs end up
thereon.

Do a google search for "mixed openmp mpi", or for "hybrid openmp mpi",
to find examples of such usage, then imagine such jobs running inside a
batch manager, on a portion of a larger system.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@engr.sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
