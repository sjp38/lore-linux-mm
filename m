Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 52D5F6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 23:37:01 -0400 (EDT)
Subject: Re: +
	memory-hotplug-alloc-page-from-other-node-in-memory-online.patch	added to
	-mm tree
From: yakui <yakui.zhao@intel.com>
In-Reply-To: <20090701025558.GA28524@sli10-desk.sh.intel.com>
References: <200906291949.n5TJnuov028806@imap1.linux-foundation.org>
	 <alpine.DEB.1.10.0906291804340.21956@gentwo.org>
	 <20090630004735.GA21254@sli10-desk.sh.intel.com>
	 <20090701025558.GA28524@sli10-desk.sh.intel.com>
Content-Type: text/plain
Date: Wed, 01 Jul 2009 11:39:03 +0800
Message-Id: <1246419543.18688.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Li, Shaohua" <shaohua.li@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-07-01 at 10:55 +0800, Li, Shaohua wrote:
> On Tue, Jun 30, 2009 at 08:47:35AM +0800, Shaohua Li wrote:
> > On Tue, Jun 30, 2009 at 06:07:16AM +0800, Christoph Lameter wrote:
> > > On Mon, 29 Jun 2009, akpm@linux-foundation.org wrote:
> > > 
> > > > To initialize hotadded node, some pages are allocated.  At that time, the
> > > > node hasn't memory, this makes the allocation always fail.  In such case,
> > > > let's allocate pages from other nodes.
> > > 
> > > Thats bad. Could you populate the buddy list with some large pages from
> > > the  beginning of the node instead of doing this special casing? The
> > > vmemmap and other stuff really should come from the node that is added.
> > > Otherwise off node memory accesses will occur constantly for processors on
> > > that node.
> > Ok, this is preferred. But the node hasn't any memory present at that time,
> > let me check how could we do it.
> Hi Christoph,
> Looks this is quite hard. Memory of the node isn't added into buddy. At that
> time (sparse-vmmem init) buddy for the node isn't initialized and even page struct
> for the hotadded memory isn't prepared too. We need something like bootmem
> allocator to get memory ...
Agree with what Shaohua said.
If we can't allocate memory from other node when there is no memory on
this node, we will have to do something like the bootmem allocator.
After the memory page is added to the system memory, we will have to
free the memory space used by the memory allocator. At the same time we
will have to assure that the hot-plugged memory exists physically. 

thanks.
   Yakui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
