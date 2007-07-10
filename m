Message-ID: <469342DC.8070007@yahoo.com.au>
Date: Tue, 10 Jul 2007 18:27:08 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 09/10] Remove the SLOB allocator for 2.6.23
References: <20070708034952.022985379@sgi.com>  <20070708035018.074510057@sgi.com> <20070708075119.GA16631@elte.hu>  <20070708110224.9cd9df5b.akpm@linux-foundation.org>  <4691A415.6040208@yahoo.com.au> <84144f020707090404l657a62c7x89d7d06b3dd6c34b@mail.gmail.com> <Pine.LNX.4.64.0707090907010.13970@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0707101049230.23040@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0707101049230.23040@sbz-30.cs.Helsinki.FI>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com, corey.d.gough@intel.com, Matt Mackall <mpm@selenic.com>, Denis Vlasenko <vda.linux@googlemail.com>, Erik Andersen <andersen@codepoet.org>
List-ID: <linux-mm.kvack.org>

Pekka J Enberg wrote:

> Curious, /proc/meminfo immediately after boot shows:
> 
> SLUB (debugging enabled):
> 
> (none):~# cat /proc/meminfo 
> MemTotal:        30260 kB
> MemFree:         22096 kB
> 
> SLUB (debugging disabled):
> 
> (none):~# cat /proc/meminfo 
> MemTotal:        30276 kB
> MemFree:         22244 kB
> 
> SLOB:
> 
> (none):~# cat /proc/meminfo 
> MemTotal:        30280 kB
> MemFree:         22004 kB
> 
> That's 92 KB advantage for SLUB with debugging enabled and 240 KB when 
> debugging is disabled.

Interesting. What kernel version are you using?


> Nick, Matt, care to retest SLUB and SLOB for your setups?

I don't think there has been a significant change in the area of
memory efficiency in either since I last tested, and Christoph and
I both produced the same result.

I can't say where SLOB is losing its memory, but there are a few
places that can still be improved, so I might get keen and take
another look at it once all the improvements to both allocators
gets upstream.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
