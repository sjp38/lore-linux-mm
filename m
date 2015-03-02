Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id C22E46B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 15:40:27 -0500 (EST)
Received: by igbhl2 with SMTP id hl2so19249046igb.0
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:40:27 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id m41si11341925ioi.38.2015.03.02.12.40.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 12:40:27 -0800 (PST)
Received: by igbhl2 with SMTP id hl2so20872955igb.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:40:27 -0800 (PST)
Date: Mon, 2 Mar 2015 12:40:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
In-Reply-To: <54F48E68.6070706@suse.cz>
Message-ID: <alpine.DEB.2.10.1503021239410.20808@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <54F469C1.9090601@suse.cz> <alpine.DEB.2.11.1503020944200.5540@gentwo.org> <54F48980.3090008@suse.cz>
 <alpine.DEB.2.11.1503021007030.6245@gentwo.org> <54F48E68.6070706@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

On Mon, 2 Mar 2015, Vlastimil Babka wrote:

> > > > You are thinking about an opportunistic allocation attempt in SLAB?
> > > > 
> > > > AFAICT SLAB allocations should trigger reclaim.
> > > > 
> > > 
> > > Well, let me quote your commit 952f3b51beb5:
> > 
> > This was about global reclaim. Local reclaim is good and that can be
> > done via zone_reclaim.
> 
> Right, so the patch is a functional change for zone_reclaim_mode == 1, where
> !__GFP_WAIT will prevent it.
> 

My patch is not a functional change, get_page_from_freelist() handles 
zone_reclaim_mode == 1 properly in the page allocator fastpath.  This 
patch only touches the slowpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
