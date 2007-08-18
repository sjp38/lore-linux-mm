Date: Fri, 17 Aug 2007 18:07:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: cpusets vs. mempolicy and how to get interleaving
In-Reply-To: <46C63BDE.20602@google.com>
Message-ID: <Pine.LNX.4.64.0708171805340.15278@schroedinger.engr.sgi.com>
References: <46C63BDE.20602@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Aug 2007, Ethan Solomita wrote:

> 	Ideally, we want a task to express its preference for interleaved
> memory allocations without having to provide a list of nodes. The kernel will
> automatically round-robin amongst the task's mems_allowed.

You can do that by writing 1 to /dev/cpuset/<cpuset>/memory_spread_page

> 	I realize that this doesn't work with backwards compatibility so I'm
> looking for advice. A new policy MPOL_INTERLEAVE_ALL that doesn't take a
> nodemask argument and interleaves within mems_allowed? Any better suggestions?

No need for a policy. Just use what I suggested above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
