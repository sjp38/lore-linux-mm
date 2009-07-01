Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 209AD6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 22:54:18 -0400 (EDT)
Date: Wed, 1 Jul 2009 10:55:58 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: +
	memory-hotplug-alloc-page-from-other-node-in-memory-online.patch
	added to -mm tree
Message-ID: <20090701025558.GA28524@sli10-desk.sh.intel.com>
References: <200906291949.n5TJnuov028806@imap1.linux-foundation.org> <alpine.DEB.1.10.0906291804340.21956@gentwo.org> <20090630004735.GA21254@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090630004735.GA21254@sli10-desk.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Zhao, Yakui" <yakui.zhao@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 08:47:35AM +0800, Shaohua Li wrote:
> On Tue, Jun 30, 2009 at 06:07:16AM +0800, Christoph Lameter wrote:
> > On Mon, 29 Jun 2009, akpm@linux-foundation.org wrote:
> > 
> > > To initialize hotadded node, some pages are allocated.  At that time, the
> > > node hasn't memory, this makes the allocation always fail.  In such case,
> > > let's allocate pages from other nodes.
> > 
> > Thats bad. Could you populate the buddy list with some large pages from
> > the  beginning of the node instead of doing this special casing? The
> > vmemmap and other stuff really should come from the node that is added.
> > Otherwise off node memory accesses will occur constantly for processors on
> > that node.
> Ok, this is preferred. But the node hasn't any memory present at that time,
> let me check how could we do it.
Hi Christoph,
Looks this is quite hard. Memory of the node isn't added into buddy. At that
time (sparse-vmmem init) buddy for the node isn't initialized and even page struct
for the hotadded memory isn't prepared too. We need something like bootmem
allocator to get memory ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
