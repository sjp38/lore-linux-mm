Subject: Re: oom-killer why ?
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <48B402B1.8030902@linux.vnet.ibm.com>
References: <48B296C3.6030706@iplabs.de>
	 <48B3E4CC.9060309@linux.vnet.ibm.com> <48B3F04B.9030308@iplabs.de>
	 <48B401F8.9010703@linux.vnet.ibm.com> <48B402B1.8030902@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 26 Aug 2008 15:09:48 -0400
Message-Id: <1219777788.24829.53.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Marco Nietz <m.nietz-mm@iplabs.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-26 at 18:48 +0530, Balbir Singh wrote:
> Balbir Singh wrote:
> 
> Looking closely, may be there is a leak like Christoph suggested (most of the
> pages have been consumed by the kernel) - only 280kB+244kB is in use by user
> pages. The rest has either leaked or in use by the kernel.
> 

There is no leak.  Between the ptepages(pagetables:152485), the
memmap(4456448 pages of RAM * 32bytes = 34816 pages) and the
slabcache(slab:35543) you can account for ~99% of the Normal zone and
its wired.  You simply cant run a large database without hugepages and
without CONFIG_HIGHPTE set and not exhaust Lowmem on a 16GB x86 system.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
