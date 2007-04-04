Date: Wed, 4 Apr 2007 15:38:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <20070404212736.GI10084@localhost>
Message-ID: <Pine.LNX.4.64.0704041531290.8127@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
 <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de> <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
 <1175544797.22373.62.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
 <1175548086.22373.99.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
 <20070404212736.GI10084@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007, Bob Picco wrote:

> Well you must have forgotten about these two postings in regards to
> performance numbers:
> http://marc.info/?l=linux-ia64&m=111990276501051&w=2
> and
> http://marc.info/?l=linux-kernel&m=116664638611634&w=2

I am well aware of those but those were done with a PAGE_SIZE vmemmap 
which is particularly bad on IA64 given the TLB fault overhead. You 
eliminated the TLB fault overhead. Virtual Memmaps need to be designed in 
such a way that they do not create additional overhead. The x86_64 version 
here has no such overhead that you could eliminate with lookup tables.

The bad thing is that this benchmark then was used to justify 
sparsemem on other platforms where such overhead does not exist.

One needs to be careful with benchmarks..... Its better to review the 
code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
