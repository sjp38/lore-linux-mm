Date: Mon, 2 Apr 2007 13:30:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <1175544797.22373.62.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
  <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
 <1175544797.22373.62.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Dave Hansen wrote:

> I completely agree, it looks like it should be faster.  The code
> certainly has potential benefits.  But, to add this neato, apparently
> more performant feature, we unfortunately have to add code.  Adding the
> code has a cost: code maintenance.  This isn't a runtime cost, but it is
> a real, honest to goodness tradeoff.

Its just the opposite. The vmemmap code is so efficient that we can remove 
lots of other code and gops of these alternate implementations. On x86_64 
its even superior to FLATMEM since FLATMEM still needs a memory reference 
for the mem_map area. So if we make SPARSE standard for all 
configurations then there is no need anymore for FLATMEM DISCONTIG etc 
etc. Can we not cleanup all this mess? Get rid of all the gazillions 
of #ifdefs please? This would ease code maintenance significantly. I hate 
having to constantly navigate my way through all the alternatives.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
