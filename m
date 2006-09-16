Date: Fri, 15 Sep 2006 19:47:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
Message-ID: <Pine.LNX.4.64.0609151944360.10817@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@osdl.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006, David Rientjes wrote:

> I used numa=fake=64 for 64 nodes of 48M each (with my numa=fake fix).  I 
> created a 2G cpuset with 43 nodes (43*48M = ~2G) and attached 'usemem -m 
> 1500 -s 10000000 &' to it for 1.5G of anonymous memory.  I then used 
> readprofile to time and profile a kernel build of 2.6.18-rc5 with x86_64 
> defconfig in the remaining 21 nodes.

Hmmm... The patch in mm for zone reduction will only get rid of 
ZONE_HIGHMEM which is not the zonelists at all.

If you have a clean x86 machine whose DMA engines can do I/O to all of 
memory then you could run with a single ZONE_NORMAL per node which may cut 
the number of tests down to a third. For that you would need the Optional 
ZONE_DMA patch that was to linux-mm this week and configure the kernel 
without ZONE_DMA and ZONE_DMA32.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
