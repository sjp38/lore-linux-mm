Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA628E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 11:37:53 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so8037971ede.14
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 08:37:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a25si5235223edb.405.2019.01.21.08.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 08:37:52 -0800 (PST)
Date: Mon, 21 Jan 2019 16:37:47 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [-next 20190118] "kernel BUG at mm/page_alloc.c:3112!"
Message-ID: <20190121163747.GL28934@suse.de>
References: <20190121154312.GH4020@osiris>
 <20190121160607.GV4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190121160607.GV4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, Michael Holzheu <holzheu@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Jan 21, 2019 at 05:06:07PM +0100, Michal Hocko wrote:
> This sounds familiar. Cc Mel and Vlastimil.
> 

There is a series sitting in Andrew's inbox that replaces a compaction
series. A patch is dropped in the new version that deals with pages
getting freed during compaction that *may* be allowing active pages to
reach the free list and not tripping a warning like it should. I'm hoping
it'll be picked up soon to see if this particular bug persists or if it's
something else.

-- 
Mel Gorman
SUSE Labs
