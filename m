Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6B8E26B004F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 09:26:33 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9B63C82C537
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 09:49:04 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2Gau9YHDCiU9 for <linux-mm@kvack.org>;
	Thu,  2 Jul 2009 09:49:04 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B167582C545
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 09:48:54 -0400 (EDT)
Date: Thu, 2 Jul 2009 09:31:04 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: + memory-hotplug-alloc-page-from-other-node-in-memory-online.patch
 added to -mm tree
In-Reply-To: <20090702144415.8B21.E1E9C6FF@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907020929060.32407@gentwo.org>
References: <1246497073.18688.28.camel@localhost.localdomain> <20090702102208.ff480a2d.kamezawa.hiroyu@jp.fujitsu.com> <20090702144415.8B21.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: yakui <yakui.zhao@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Jul 2009, Yasunori Goto wrote:

> However, I don't enough time for memory hotplug now,
> and they are just redundant functions now.
> If someone create new allocator (and unifying bootmem allocator),
> I'm very glad. :-)

"Senior"ities all around.... A move like that would require serious
commitment of time. None of us older developers can take that on it
seems.

Do we need to accept that the zone and page metadata are living on another
node?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
