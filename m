Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7VFnTED027203
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 11:49:29 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7VFnSFB091192
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 09:49:28 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7VFnSMc011337
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 09:49:28 -0600
Date: Thu, 31 Aug 2006 08:49:48 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: libnuma interleaving oddness
Message-ID: <20060831154948.GA23990@us.ibm.com>
References: <20060829231545.GY5195@us.ibm.com> <Pine.LNX.4.64.0608301401290.4217@schroedinger.engr.sgi.com> <20060831060036.GA18661@us.ibm.com> <200608310947.30542.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200608310947.30542.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 31.08.2006 [09:47:30 +0200], Andi Kleen wrote:
> On Thursday 31 August 2006 08:00, Nishanth Aravamudan wrote:
> > On 30.08.2006 [14:04:40 -0700], Christoph Lameter wrote:
> > > > I took out the mlock() call, and I get the same results, FWIW.
> > > 
> > > What zones are available on your box? Any with HIGHMEM?
> > 
> > How do I tell the available zones from userspace? This is ppc64 with
> > about 64GB of memory total, it looks like. So, none of the nodes
> > (according to /sys/devices/system/node/*/meminfo) have highmem.
> 
> The zones are listed at the beginning of dmesg
> 
> "On node X total pages ...
>       DMA zone ...
>       ..." 

Page orders: linear mapping = 24, others = 12
<snip>
[boot]0100 MM Init
[boot]0100 MM Init Done
Linux version 2.6.16.21-0.8-ppc64 (geeko@buildhost) (gcc version 4.1.0 (SUSE Linux)) #1 SMP Mon Jul 3 18:25:39 UTC 2006
[boot]0012 Setup Arch
Node 0 Memory: 0x0-0x1b0000000
Node 1 Memory: 0x1b0000000-0x3b0000000
Node 2 Memory: 0x3b0000000-0x5b0000000
Node 3 Memory: 0x5b0000000-0x7b0000000
Node 4 Memory: 0x7b0000000-0x9a0000000
Node 5 Memory: 0x9a0000000-0xba0000000
Node 6 Memory: 0xba0000000-0xda0000000
Node 7 Memory: 0xda0000000-0xf90000000
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 7168 bytes
Using dedicated idle loop
On node 0 totalpages: 1769472
  DMA zone: 1769472 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
On node 1 totalpages: 2097152
  DMA zone: 2097152 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
On node 2 totalpages: 2097152
  DMA zone: 2097152 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
On node 3 totalpages: 2097152
  DMA zone: 2097152 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
On node 4 totalpages: 2031616
  DMA zone: 2031616 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
On node 5 totalpages: 2097152
  DMA zone: 2097152 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
On node 6 totalpages: 2097152
  DMA zone: 2097152 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
On node 7 totalpages: 2031616
  DMA zone: 2031616 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
[boot]0015 Setup Done
Built 8 zonelists

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
