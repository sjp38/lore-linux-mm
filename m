Subject: Re: [PATCH 0/4] VM deadlock prevention -v5
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0608250849480.9083@schroedinger.engr.sgi.com>
References: <20060825153946.24271.42758.sendpatchset@twins>
	 <Pine.LNX.4.64.0608250849480.9083@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 25 Aug 2006 17:52:04 +0200
Message-Id: <1156521124.23000.1.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Indan Zupancic <indan@nul.nu>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-08-25 at 08:51 -0700, Christoph Lameter wrote:
> On Fri, 25 Aug 2006, Peter Zijlstra wrote:
> 
> > The basic premises is that network sockets serving the VM need undisturbed
> > functionality in the face of severe memory shortage.
> > 
> > This patch-set provides the framework to provide this.
> 
> Hmmm.. Is it not possible to avoid the memory pools by 
> guaranteeing that a certain number of page is easily reclaimable?

We're not actually using mempools, but the memalloc reserve. Purely easy
reclaimable memory is not enough however, since packet receive happens
from IRQ context, and we cannot unmap pages in IRQ context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
