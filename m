Date: Tue, 22 Jan 2008 15:14:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <20080122231058.GB866@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0801221513100.2565@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com>
 <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
 <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
 <Pine.LNX.4.64.0801221203340.27950@schroedinger.engr.sgi.com>
 <20080122212654.GB15567@csn.ul.ie> <Pine.LNX.4.64.0801221330390.1652@schroedinger.engr.sgi.com>
 <20080122225046.GA866@csn.ul.ie> <Pine.LNX.4.64.0801221453480.2271@schroedinger.engr.sgi.com>
 <20080122231058.GB866@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Olaf Hering <olaf@aepfle.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2008, Mel Gorman wrote:

> Rather it should be 2. I'll admit the physical setup of this machine is
> .... less than ideal but clearly it's something that can happen even if
> it's a bad idea.

Ok. Lets hope that Pekka's find does the trick. But this would mean that 
fallback gets memory from node 2 for the page allocator. Then fallback 
alloc is going to try to insert it into the l3 of node 2 which is not 
there yet. So another ooops. Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
