Date: Wed, 12 Sep 2007 17:36:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 24] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <20070912054229.1073f55d.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709121734380.4489@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random> <edb3af3e0d4f2c083c8d.1187786937@v2.random>
 <20070912054229.1073f55d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Andrew Morton wrote:

> Also, the oom-killer is cpuset aware.  Won't this change cause an
> oom-killing in cpuset A to needlessly disrupt processes running in cpuset
> B?

Right. I remember reviewing this before. One could maybe set a OOM flag 
per cpuset? But then OOM conditions can also be specific to a memory 
policy (MPOL_BIND) or to a particular node (GFP_THISNODE).

Maybe the best solution would be to set a per zone OOM flag?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
