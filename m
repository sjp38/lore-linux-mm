Date: Tue, 17 May 2005 16:49:23 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: NUMA aware slab allocator V3
In-Reply-To: <428A800D.8050902@us.ibm.com>
Message-ID: <Pine.LNX.4.62.0505171648370.17681@graphe.net>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
 <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>
 <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>
 <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net>
 <1116289613.26955.14.camel@localhost> <428A800D.8050902@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Jesse Barnes <jbarnes@virtuousgeek.org>, Christoph Lameter <clameter@engr.sgi.com>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 17 May 2005, Matthew Dobson wrote:

> You're right, Dave.  The series of #defines at the top resolve to the same
> thing as numa_node_id().  Adding the above #defines will serve only to
> obfuscate the code.

Ok.
 
> Another thing that will really help, Christoph, would be replacing all your
> open-coded for (i = 0; i < MAX_NUMNODES/NR_CPUS; i++) loops.  We have
> macros that make that all nice and clean and (should?) do the right thing
> for various combinations of SMP/DISCONTIG/NUMA/etc.  Use those and if they
> DON'T do the right thing, please let me know and we'll fix them ASAP.

Some of that was already done but I can check again.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
