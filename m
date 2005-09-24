Date: Sat, 24 Sep 2005 13:12:34 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] Use node macros for memory policies
Message-Id: <20050924131234.427e40ef.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509241119490.29070@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0509231109001.22542@schroedinger.engr.sgi.com>
	<20050923145746.77a846b7.akpm@osdl.org>
	<Pine.LNX.4.62.0509241119490.29070@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew inquired:
> Which typedef weenie inflicted nodemask_t upon us anyway?

I believe it was Matthew Dobson and myself, with forced labor
contributions from several others, as part of a larger effort
to overhaul bitmaps and cpumasks.


Christoph wrote:
> One hunk is missing in Andi's patchset. This covers the cpuset->mempolicy 
> interface.

If you had taken a look at the lkml thread where Andi submitted his
patch to convert mempolicy to nodemask, and I reviewed it, we agreed to
send in the remaining couple of pieces after Andi's patch had worked
its way through the system, to avoid wasting the couple of minutes of
Andrews time that it would take him to deal with possible merge
conflicts.


I don't see where your patch deals with the following two lines, at the
point in mm/mempolicy.c where cpuset_restrict_to_mems_allowed is called
(the latest *-mm version with Andi's patch nodemask mempolicy patch):

        /* AK: shouldn't this error out instead? */
        cpuset_restrict_to_mems_allowed(nodes_addr(*nodes));

I agreed with Andi that this should error out, and I accepted his
suggestion that I fix this, later on.

Surely it is not a good idea to change the type of parameter a function
accepts, without changing the places that call that function.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
