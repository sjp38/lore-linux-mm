Date: Fri, 13 Jul 2007 16:28:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
In-Reply-To: <20070714082736.10af5f13.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0707131628150.27014@schroedinger.engr.sgi.com>
References: <617E1C2C70743745A92448908E030B2A01EA65B9@scsmsx411.amr.corp.intel.com>
 <Pine.LNX.4.64.0707131553120.26572@schroedinger.engr.sgi.com>
 <20070714082736.10af5f13.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: tony.luck@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org, npiggin@suse.de, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jul 2007, KAMEZAWA Hiroyuki wrote:

> > I'd be very surprised if there is any difference because the IA64 code for 
> > virtual memmap is the source of ideas and implementation for SPARSE_VIRTUAL.
> > 
> Maybe pfn_valid() implementation is different from ?

Right but that should increase the speed and not decrease it since we do 
not have the CONFIG HOLES anymore.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
