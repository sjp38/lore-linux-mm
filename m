Date: Wed, 12 Sep 2007 18:02:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 23 of 24] serialize for cpusets
In-Reply-To: <20070912061003.39506e07.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709121801490.4489@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random> <a3d679df54ebb1f977b9.1187786950@v2.random>
 <20070912061003.39506e07.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Andrew Morton wrote:

> I understand that SGI's HPC customers care rather a lot about oom handling
> in cpusets.  It'd be nice if people@sgi could carefully review-and-test
> changes such as this before we go and break stuff for them, please.

Is there some way that we can consolidate the cpuset and the !cpuset case? 
We have a cpuset_lock() for the cpuset case and now also the OOM bit. If 
both fall back to global in case of !CPUSET then we may be able to clean 
this up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
