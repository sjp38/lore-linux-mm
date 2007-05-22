Date: Tue, 22 May 2007 09:58:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc] increase struct page size?!
Message-Id: <20070522095836.c01263ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705211737450.24160@schroedinger.engr.sgi.com>
References: <20070518040854.GA15654@wotan.suse.de>
	<Pine.LNX.4.64.0705191121480.17008@schroedinger.engr.sgi.com>
	<464FCA28.9040009@cosmosbay.com>
	<200705201456.26283.ak@suse.de>
	<Pine.LNX.4.64.0705211006550.26282@schroedinger.engr.sgi.com>
	<20070522093050.0320d092.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705211737450.24160@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: ak@suse.de, dada1@cosmosbay.com, wli@holomorphy.com, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 May 2007 17:38:58 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:
> 
> > For i386(32bit arch), there is not enough space for vmemmap.
> 
> I thought 32 bit would use flatmem? Is memory really sparse on 32 
> bit? Likely difficult due to lack of address space?
> 

Of course, i386 can use flatmem.

I am just afraid that memory hotplug is just for sprasemem.
But I also think we can add memory-hotplug for flatmem if necessary.
(I myself have no plan now. I wonder memory power-save-mode may be supported
 by chipsets.)

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
