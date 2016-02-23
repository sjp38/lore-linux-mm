Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 86FED6B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:15:31 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id z135so220198231iof.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:15:31 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id n4si4259276igv.3.2016.02.23.09.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 09:15:30 -0800 (PST)
Date: Tue, 23 Feb 2016 11:15:29 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 00/27] Move LRU page reclaim from zones to nodes v2
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1602231114110.13246@east.gentwo.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Tue, 23 Feb 2016, Mel Gorman wrote:

> Conceptually, moving to node LRUs should be easier to understand. The
> page allocator plays fewer tricks to game reclaim and reclaim behaves
> similarly on all nodes.

I think this is a good way to simplify reclaim and limit the nasty effects
of zones a bit. It probably would allow us to long term rely less on
zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
