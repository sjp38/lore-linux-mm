Date: Sat, 14 Jul 2007 08:27:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
Message-Id: <20070714082736.10af5f13.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0707131553120.26572@schroedinger.engr.sgi.com>
References: <617E1C2C70743745A92448908E030B2A01EA65B9@scsmsx411.amr.corp.intel.com>
	<Pine.LNX.4.64.0707131553120.26572@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: tony.luck@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org, npiggin@suse.de, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007 15:54:25 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 13 Jul 2007, Luck, Tony wrote:
> 
> > > How many tests were done and on what platform?
> > 
> > Andy's part 0/7 post starts off with the performance numbers.  He
> > didn't say which ia64 platform was used for the tests.
> > 
> > Looking my logs for the last few kernel builds (some built on a
> > tiger_defconfig kernel which uses CONFIG_VIRTUAL_MEM_MAP=y, and
> > some with the new CONFIG_SPARSEMEM_VMEMMAP) I'd have a tough time
> > saying whether there was a regression or not).
> 
> I'd be very surprised if there is any difference because the IA64 code for 
> virtual memmap is the source of ideas and implementation for SPARSE_VIRTUAL.
> 
Maybe pfn_valid() implementation is different from ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
