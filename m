Date: Mon, 2 Apr 2007 15:29:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <1175550968.22373.122.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704021526390.23601@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
  <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
  <1175544797.22373.62.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
 <1175548086.22373.99.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
 <1175550968.22373.122.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Dave Hansen wrote:

> On Mon, 2007-04-02 at 14:28 -0700, Christoph Lameter wrote:
> > I do not care what its called as long as it 
> > covers all the bases and is not a glaring performance regresssion (like 
> > SPARSEMEM so far). 
> 
> I honestly don't doubt that there are regressions, somewhere.  Could you
> elaborate, and perhaps actually show us some numbers on this?  Perhaps
> instead of adding a completely new model, we can adapt the existing ones
> somehow.

Just look at pfn_to_page and friends on ia64 and see what atrocities 
sparsemem does with those if you enable it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
