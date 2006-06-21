Date: Tue, 20 Jun 2006 17:34:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/3] 2.6.17 radix-tree: updates and lockless
In-Reply-To: <1150847428.1901.60.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0606201732580.14331@schroedinger.engr.sgi.com>
References: <20060408134635.22479.79269.sendpatchset@linux.site>
 <20060620153555.0bd61e7b.akpm@osdl.org>  <1150844989.1901.52.camel@localhost.localdomain>
  <20060620163037.6ff2c8e7.akpm@osdl.org> <1150847428.1901.60.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@osdl.org>, npiggin@suse.de, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jun 2006, Benjamin Herrenschmidt wrote:

> Anyway, I can drop a spinlock in (in fact I have) the ppc64 irq code for
> now but that sucks, thus we should really seriously consider having the
> lockless tree in 2.6.18 or I might have to look into doing an alternate
> implementation specifically in arch code... or find some other way of
> doing the inverse mapping there...

How many interrupts do you have to ? I would expect a simple table 
lookup would be fine to get from the virtual to the real interrupt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
