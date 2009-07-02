Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7627A6B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 21:09:43 -0400 (EDT)
Subject: Re: +
	memory-hotplug-alloc-page-from-other-node-in-memory-online.patch added to
	-mm tree
From: yakui <yakui.zhao@intel.com>
In-Reply-To: <alpine.DEB.1.10.0907011317030.9522@gentwo.org>
References: <200906291949.n5TJnuov028806@imap1.linux-foundation.org>
	 <alpine.DEB.1.10.0906291804340.21956@gentwo.org>
	 <20090630004735.GA21254@sli10-desk.sh.intel.com>
	 <20090701025558.GA28524@sli10-desk.sh.intel.com>
	 <1246419543.18688.14.camel@localhost.localdomain>
	 <alpine.DEB.1.10.0907011317030.9522@gentwo.org>
Content-Type: text/plain
Date: Thu, 02 Jul 2009 09:11:13 +0800
Message-Id: <1246497073.18688.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-07-02 at 01:22 +0800, Christoph Lameter wrote:
> On Wed, 1 Jul 2009, yakui wrote:
> 
> > If we can't allocate memory from other node when there is no memory on
> > this node, we will have to do something like the bootmem allocator.
> > After the memory page is added to the system memory, we will have to
> > free the memory space used by the memory allocator. At the same time we
> > will have to assure that the hot-plugged memory exists physically.
> 
> The bootmem allocator must stick around it seems. Its more like a node
> bootstrap allocator then.
> 
> Maybe we can generalize that. The bootstrap allocator may only need to be
> able boot one node (which simplifies design). During system bringup only
> the boot node is brought up.
> 
> Then the other nodes are hotplugged later all in turn using the bootstrap
> allocator for their node setup?
Your idea looks fragrant. But it seems that it is difficult to realize.
In the boot phase the bootmem allocator is initialized. And after the
page buddy mechanism is enabled, the memory space used by bootmem
allocator will be freed.

If we also do the similar thing for the hotplugged node, how and when to
free the memory space used by the bootstrap allocator? It seems that we
will have to wait before all the memory sections are onlined for this
hotplugged node. And before all the memory sections are onlined, the
bootstrap allocator and buddy page allocator will co-exist.

thanks.
> 
> There are a couple of things where one would want to spread out memory
> across the nodes at boot time. How would node hotplugging handle that
> situation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
