Subject: Re: slab fragmentation ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <41617567.9010507@colorfullife.com>
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>
	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]>
	 <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>
	 <415F968B.8000403@colorfullife.com>
	 <1096905099.12861.117.camel@dyn318077bld.beaverton.ibm.com>
	 <41617567.9010507@colorfullife.com>
Content-Type: multipart/mixed; boundary="=-95RiFpVH+ndSNUEOifFQ"
Message-Id: <1096987570.12861.122.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 05 Oct 2004 07:46:11 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-95RiFpVH+ndSNUEOifFQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2004-10-04 at 09:08, Manfred Spraul wrote:
> Badari Pulavarty wrote:
> 
> >I will enable slab debugging. Someone told me that, by enabling slab
> >debug, it fill force use of different slab for each allocation - there
> >by bloating slab usages and mask the problem. Is it true ?
> >
> >  
> >
> Then set STATS to 1. It's around line 118. This just adds full 
> statistics without changing the allocations.
> Or even better: enable STATS and DEBUG, but not FORCED_DEBUG. You get 
> most internal consistance checks as well, except the tests that rely on 
> redzoning.

Here is the /proc/slabinfo output collected every 1 second while
running the scsi-debug test. I enabled STATS and DEBUG.

Please let me know, what you find and what we should try next.

Thanks,
Badari



--=-95RiFpVH+ndSNUEOifFQ
Content-Disposition: attachment; filename=slab.out
Content-Type: text/plain; name=slab.out; charset=UTF-8
Content-Transfer-Encoding: 7bit

# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <batchcount> <limit> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail> : globalstat <listallocs> <maxobjs> <grown> <reaped> <error> <maxfreeable> <freelimit> : cpustat <allochit> <allocmiss> <freehit> <freemiss>
size-40             2088   9760     64   61    1 : tunables   32   16    8 : slabdata    160    160      0 : globalstat    3324   2010   160    0    0    0  173 : cpustat   5675    213   3945      2
size-40             2088   9760     64   61    1 : tunables   32   16    8 : slabdata    160    160      0 : globalstat    3324   2010   160    0    0    0  173 : cpustat   5675    213   3945      2
size-40             2088   9760     64   61    1 : tunables   32   16    8 : slabdata    160    160      0 : globalstat    3324   2010   160    0    0    0  173 : cpustat   5675    213   3945      2
size-40             4582  31110     64   61    1 : tunables   32   16    8 : slabdata    510    510      0 : globalstat    5468   4085   510    0    0    0  173 : cpustat   7924    347   4247      2
size-40             7246  55022     64   61    1 : tunables   32   16    8 : slabdata    902    902      0 : globalstat    7740   6357   902    0    0    0  173 : cpustat  10405    489   4583      2
size-40            10146  80642     64   61    1 : tunables   32   16    8 : slabdata   1322   1322      0 : globalstat   10220   8837  1322    0    0    0  173 : cpustat  13055    644   4941      2
size-40            12959 105835     64   61    1 : tunables   32   16    8 : slabdata   1735   1735      0 : globalstat   12620  11237  1735    0    0    0  173 : cpustat  15685    794   5295      2
size-40            15765 130601     64   61    1 : tunables   32   16    8 : slabdata   2141   2141      0 : globalstat   15020  13637  2141    0    0    0  173 : cpustat  18304    944   5649      2
size-40            18697 156221     64   61    1 : tunables   32   16    8 : slabdata   2561   2561      0 : globalstat   17532  16149  2561    0    0    0  173 : cpustat  20988   1101   6009      2
size-40            21315 179279     64   61    1 : tunables   32   16    8 : slabdata   2939   2939      0 : globalstat   19772  18389  2939    0    0    0  173 : cpustat  23418   1241   6335      2
size-40            24073 204045     64   61    1 : tunables   32   16    8 : slabdata   3345   3345      0 : globalstat   22124  20741  3345    0    0    0  173 : cpustat  25984   1388   6681      2
size-40            26730 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7013      2
size-40            26730 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7013      2
size-40            26723 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7013      2
size-40            26708 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7013      2
size-40            26701 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7013      2
size-40            26696 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7013      2
size-40            26691 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7015      2
size-40            26687 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7015      2
size-40            26685 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7015      2
size-40            26685 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7015      2
size-40            26683 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7018      2
size-40            26682 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7018      2
size-40            26682 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7018      2
size-40            26680 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7021      2
size-40            26680 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7021      2
size-40            26679 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7021      2
size-40            26679 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7021      2
size-40            26676 227530     64   61    1 : tunables   32   16    8 : slabdata   3730   3730      0 : globalstat   24396  23013  3730    0    0    0  173 : cpustat  28454   1530   7025      2

--=-95RiFpVH+ndSNUEOifFQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
