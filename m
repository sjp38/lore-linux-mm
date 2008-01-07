Date: Mon, 7 Jan 2008 10:23:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-Id: <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080103155046.GA7092@skywalker>
References: <20071220100541.GA6953@skywalker>
	<20071225140519.ef8457ff.akpm@linux-foundation.org>
	<20071227153235.GA6443@skywalker>
	<Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com>
	<20071228051959.GA6385@skywalker>
	<Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
	<20080103155046.GA7092@skywalker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, nacc@us.ibm.com, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008 21:20:46 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> Node: 0, start_pfn: 0, end_pfn: 156
> Node: 0, start_pfn: 256, end_pfn: 917393
> Node: 0, start_pfn: 1048576, end_pfn: 2752512
> get_memcfg_from_srat: assigning address to rsdp
> RSD PTR  v0 [IBM   ]
> Begin SRAT table scan....
> CPU 0x00 in proximity domain 0x00
> CPU 0x02 in proximity domain 0x00
> CPU 0x10 in proximity domain 0x00
> CPU 0x12 in proximity domain 0x00
> Memory range 0x0 to 0xE0000 (type 0x0) in proximity domain 0x00 enabled
> Memory range 0x100000 to 0x120000 (type 0x0) in proximity domain 0x00 enabled
> CPU 0x20 in proximity domain 0x01
> CPU 0x22 in proximity domain 0x01
> CPU 0x30 in proximity domain 0x01
> CPU 0x32 in proximity domain 0x01
> Memory range 0x120000 to 0x2A0000 (type 0x0) in proximity domain 0x01 enabled
> acpi20_parse_srat: Entry length value is zero; can't parse any further!
> pxm bitmap: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
> Number of logical nodes in system = 2
> Number of memory chunks in system = 3
> chunk 0 nid 0 start_pfn 00000000 end_pfn 000e0000
> chunk 1 nid 0 start_pfn 00100000 end_pfn 00120000
> chunk 2 nid 1 start_pfn 00120000 end_pfn 002a0000
> Node: 0, start_pfn: 0, end_pfn: 1179648
> Node: 1, start_pfn: 1179648, end_pfn: 2752512

Seems Node 1 has no NORMAL memory.

Because the patch changes 'online_node' to N_NORMAL_MEMORY, there is a change.
I'm not sure but cachep->nodelists[] should be created against all online nodes ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
