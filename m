Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF4AE6B0038
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:09:10 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id at1so7349844iec.30
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 14:09:10 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id ab4si10520912igd.52.2014.07.21.14.09.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 14:09:10 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 15:09:08 -0600
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id DB8556E802D
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:08:54 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LL94Kh66977866
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 21:09:04 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6LL94qQ031776
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:09:04 -0400
Date: Mon, 21 Jul 2014 14:09:00 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 15/30] mm, igb: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140721210900.GI4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com>
 <20140721174218.GD4156@linux.vnet.ibm.com>
 <CAKgT0UdZdbduP-=R7uRCxJVxt1yCDoHpnercnDoyrCbWNtx=6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UdZdbduP-=R7uRCxJVxt1yCDoHpnercnDoyrCbWNtx=6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Bruce Allan <bruce.w.allan@intel.com>, Carolyn Wyborny <carolyn.wyborny@intel.com>, Don Skidmore <donald.c.skidmore@intel.com>, Greg Rose <gregory.v.rose@intel.com>, Alex Duyck <alexander.h.duyck@intel.com>, John Ronciak <john.ronciak@intel.com>, Mitch Williams <mitch.a.williams@intel.com>, Linux NICS <linux.nics@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>

On 21.07.2014 [12:53:33 -0700], Alexander Duyck wrote:
> I do agree the description should probably be changed.  There shouldn't be
> any panics involved, only a performance impact as it will be reallocating
> always if it is on a node with no memory.

Yep, thanks for the review.

> My intention on this was to make certain that the memory used is from the
> closest node possible.  As such I believe this change likely honours that.

Absolutely, just wanted to make it explicit that it's not a functional
fix, just a performance fix (presuming this shows up at all on systems
that have memoryless NUMA nodes).

I'd suggest an update to the comments, as well.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
