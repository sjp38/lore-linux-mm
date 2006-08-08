Date: Tue, 8 Aug 2006 11:29:58 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] Slab: Enforce clean node lists per zone, add policy
 support and fallback
Message-Id: <20060808112958.12b71fb4.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608080951240.27620@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080951240.27620@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, kiran@scalex86.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Rather than special casing __cache_alloc_node() to handle the
fallback to other nodes when __GFP_THISNODE was -not- set, it might be
clearer to go the custom, single node zonelist (MPOL_BIND-like?)
approach, with no __GFP_THISNODE flag, for the few calls that do
require exact node placement.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
