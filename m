Message-ID: <461169CF.6060806@google.com>
Date: Mon, 02 Apr 2007 13:38:39 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>  <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>  <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com> <1175544797.22373.62.camel@localhost.localdomain> <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 2 Apr 2007, Dave Hansen wrote:
> 
>> I completely agree, it looks like it should be faster.  The code
>> certainly has potential benefits.  But, to add this neato, apparently
>> more performant feature, we unfortunately have to add code.  Adding the
>> code has a cost: code maintenance.  This isn't a runtime cost, but it is
>> a real, honest to goodness tradeoff.
> 
> Its just the opposite. The vmemmap code is so efficient that we can remove 
> lots of other code and gops of these alternate implementations. On x86_64 
> its even superior to FLATMEM since FLATMEM still needs a memory reference 
> for the mem_map area. So if we make SPARSE standard for all 
> configurations then there is no need anymore for FLATMEM DISCONTIG etc 
> etc. Can we not cleanup all this mess? Get rid of all the gazillions 
> of #ifdefs please? This would ease code maintenance significantly. I hate 
> having to constantly navigate my way through all the alternatives.

The original plan when this was first merged was pretty much that -
for sparsemem to replace discontigmem once it was well tested. Seems
to have got stalled halfway through ;-(

Not sure we'll get away with replacing flatmem for all arches, but
we could at least get rid of discontigmem, it seems.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
