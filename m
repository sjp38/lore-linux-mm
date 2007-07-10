Message-ID: <46935AE5.7050205@yahoo.com.au>
Date: Tue, 10 Jul 2007 20:09:41 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 09/10] Remove the SLOB allocator for 2.6.23
References: <20070708034952.022985379@sgi.com>	 <20070708035018.074510057@sgi.com> <20070708075119.GA16631@elte.hu>	 <20070708110224.9cd9df5b.akpm@linux-foundation.org>	 <4691A415.6040208@yahoo.com.au>	 <84144f020707090404l657a62c7x89d7d06b3dd6c34b@mail.gmail.com>	 <Pine.LNX.4.64.0707090907010.13970@schroedinger.engr.sgi.com>	 <Pine.LNX.4.64.0707101049230.23040@sbz-30.cs.Helsinki.FI>	 <469342DC.8070007@yahoo.com.au> <84144f020707100231p5013e1aer767562c26fc52eeb@mail.gmail.com>
In-Reply-To: <84144f020707100231p5013e1aer767562c26fc52eeb@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com, corey.d.gough@intel.com, Matt Mackall <mpm@selenic.com>, Denis Vlasenko <vda.linux@googlemail.com>, Erik Andersen <andersen@codepoet.org>
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Hi Nick,
> 
> Pekka J Enberg wrote:
> 
>> > That's 92 KB advantage for SLUB with debugging enabled and 240 KB when
>> > debugging is disabled.
> 
> 
> On 7/10/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> Interesting. What kernel version are you using?
> 
> 
> Linus' git head from yesterday so the results are likely to be
> sensitive to workload and mine doesn't represent real embedded use.

Hi Pekka,

There is one thing that the SLOB patches in -mm do besides result in
slightly better packing and memory efficiency (which might be unlikely
to explain the difference you are seeing), and that is that they do
away with the delayed freeing of unused SLOB pages back to the page
allocator.

In git head, these pages are freed via a timer so they can take a
while to make their way back to the buddy allocator so they don't
register as free memory as such.

Anyway, I would be very interested to see any situation where the
SLOB in -mm uses more memory than SLUB, even on test configs like
yours.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
