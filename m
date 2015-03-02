Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id B95C96B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 10:46:36 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id z107so5416906qgd.3
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 07:46:36 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id c91si11856943qgc.92.2015.03.02.07.46.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 07:46:35 -0800 (PST)
Date: Mon, 2 Mar 2015 09:46:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
In-Reply-To: <54F469C1.9090601@suse.cz>
Message-ID: <alpine.DEB.2.11.1503020944200.5540@gentwo.org>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <54F469C1.9090601@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

On Mon, 2 Mar 2015, Vlastimil Babka wrote:

> So it would be IMHO better for longer-term maintainability to have the
> relevant __GFP_THISNODE callers pass also __GFP_NO_KSWAPD to denote these
> opportunistic allocation attempts, instead of having this subtle semantic

You are thinking about an opportunistic allocation attempt in SLAB?

AFAICT SLAB allocations should trigger reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
