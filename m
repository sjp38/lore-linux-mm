Date: Wed, 23 Jan 2008 10:41:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix boot problem in situations where the boot CPU is
 running on a memoryless node
In-Reply-To: <20080123135513.GA14175@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0801231040160.11430@schroedinger.engr.sgi.com>
References: <20080118213011.GC10491@csn.ul.ie>
 <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
 <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
 <20080122214505.GA15674@aepfle.de> <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com>
 <20080123075821.GA17713@aepfle.de> <20080123105044.GD21455@csn.ul.ie>
 <20080123121459.GA18631@aepfle.de> <20080123125236.GA18876@aepfle.de>
 <20080123135513.GA14175@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, Olaf Hering <olaf@aepfle.de>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Mel Gorman wrote:

> This patch adds the necessary checks to make sure a kmem_list3 exists for
> the preferred node used when growing the cache. If the preferred node has
> no nodelist then the currently running node is used instead. This
> problem only affects the SLAB allocator, SLUB appears to work fine.

That is a dangerous thing to do. SLAB per cpu queues will contain foreign 
objects which may cause troubles when pushing the objects back. I think we 
may be lucky that these objects are consumed at boot. If all of the 
foreign objects are consumed at boot then we are fine. At least an 
explanation as to this issue should be added to the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
