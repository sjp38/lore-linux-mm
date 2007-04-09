Date: Mon, 9 Apr 2007 10:16:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: (SPARSE_VIRTUAL doubles sparsemem speed)
In-Reply-To: <20070409164029.GT2986@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0704091014350.4878@schroedinger.engr.sgi.com>
References: <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de> <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
 <1175544797.22373.62.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
 <461169CF.6060806@google.com> <Pine.LNX.4.64.0704021345110.1224@schroedinger.engr.sgi.com>
 <4614E293.3010908@shadowen.org> <Pine.LNX.4.64.0704051119400.9800@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704071455060.31468@schroedinger.engr.sgi.com>
 <20070409164029.GT2986@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Martin Bligh <mbligh@google.com>, Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Apr 2007, William Lee Irwin III wrote:

> Whatever's going on with the rest of this, I really like this
> instrumentation patch. It may be worthwhile to allow pc_start() to be
> overridden so things like performance counter MSR's are usable, but
> the framework looks very useful.

Yeah. I also did some measurements on quicklists on x86_64 and it seems 
that caching page table pages is also useful:

no quicklist

pte_alloc               1569048 4.3s(401ns/2.7us/179.7us)
pmd_alloc                780988 2.1s(337ns/2.7us/86.1us)
pud_alloc                780072 2.2s(424ns/2.8us/300.6us)
pgd_alloc                260022 1s(920ns/4us/263.1us)

quicklist:

pte_alloc                452436 573.4ms(8ns/1.3us/121.1us)
pmd_alloc                196204 174.5ms(7ns/889ns/46.1us)
pud_alloc                195688 172.4ms(7ns/881ns/151.3us)
pgd_alloc                 65228 9.8ms(8ns/150ns/6.1us)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
