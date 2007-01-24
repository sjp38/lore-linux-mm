Received: by wx-out-0506.google.com with SMTP id s8so75031wxc
        for <linux-mm@kvack.org>; Tue, 23 Jan 2007 21:47:45 -0800 (PST)
Message-ID: <6d6a94c50701232147g7453fe79q6ce0df94da2ac749@mail.gmail.com>
Date: Wed, 24 Jan 2007 13:47:44 +0800
From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <20070124115310.48cda374.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	 <20070124115310.48cda374.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, rgetz@blackfin.uclinux.org, Michael.Hennerich@analog.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bryan Wu <cooloney.lkml@gmail.com>
List-ID: <linux-mm.kvack.org>

Christoph's patch is better than mine. The only thing I think is that
zone->max_pagecache_pages should be checked never less than
zone->pages_low.

The good part of the patch is using the existing reclaimer. But the
problem in my opinion of the idea is the existing reclaimer too. Think
of  when vfs cache limit is
hit, reclaimer doesn't reclaim all of the reclaimable pages, it just
give few out. So next time vfs pagecache request, it is quite possible
reclaimer is triggered again. That means after limit is hit, reclaim
will be implemented every time fs ops allocating memory. That's the
point in my mind impacting the performance of the applications.

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
