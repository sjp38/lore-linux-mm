Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D24336B005A
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:22:01 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9E72D82C3A9
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:40:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZPwrkC0YecBg for <linux-mm@kvack.org>;
	Wed,  1 Jul 2009 13:40:22 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E4C9282C432
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:40:17 -0400 (EDT)
Date: Wed, 1 Jul 2009 13:22:33 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: + memory-hotplug-alloc-page-from-other-node-in-memory-online.patch
 added to -mm tree
In-Reply-To: <1246419543.18688.14.camel@localhost.localdomain>
Message-ID: <alpine.DEB.1.10.0907011317030.9522@gentwo.org>
References: <200906291949.n5TJnuov028806@imap1.linux-foundation.org>  <alpine.DEB.1.10.0906291804340.21956@gentwo.org>  <20090630004735.GA21254@sli10-desk.sh.intel.com>  <20090701025558.GA28524@sli10-desk.sh.intel.com>
 <1246419543.18688.14.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: yakui <yakui.zhao@intel.com>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jul 2009, yakui wrote:

> If we can't allocate memory from other node when there is no memory on
> this node, we will have to do something like the bootmem allocator.
> After the memory page is added to the system memory, we will have to
> free the memory space used by the memory allocator. At the same time we
> will have to assure that the hot-plugged memory exists physically.

The bootmem allocator must stick around it seems. Its more like a node
bootstrap allocator then.

Maybe we can generalize that. The bootstrap allocator may only need to be
able boot one node (which simplifies design). During system bringup only
the boot node is brought up.

Then the other nodes are hotplugged later all in turn using the bootstrap
allocator for their node setup?

There are a couple of things where one would want to spread out memory
across the nodes at boot time. How would node hotplugging handle that
situation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
