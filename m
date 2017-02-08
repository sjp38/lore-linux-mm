Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B1A346B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:40:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r18so31352900wmd.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:40:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11si9341718wrb.215.2017.02.08.06.40.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 06:40:01 -0800 (PST)
Date: Wed, 8 Feb 2017 15:39:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170208143959.GN5686@dhcp22.suse.cz>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170207094557.GE5065@dhcp22.suse.cz>
 <20170207153247.GB31837@WeideMBP.lan>
 <20170207154120.GW5065@dhcp22.suse.cz>
 <20170208140518.GA67800@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170208140518.GA67800@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 08-02-17 22:05:18, Wei Yang wrote:
[...]
> BTW, the ZONE_MOVABLE handling looks strange to me and the comment "Treat
> pages to be ZONE_MOVABLE in ZONE_NORMAL as absent pages and vice versa" is
> hard to understand. From the code point of view, if zone_type is ZONE_NORMAL,
> each memblock region between zone_start_pfn and zone_end_pfn would be treated
> as absent pages if it is not mirrored. Do you have some hint on this?

Not really, sorry, this area is full of awkward and subtle code when new
changes build on top of previous awkwardness/surprises. Any cleanup
would be really appreciated. That is the reason I didn't like the
initial check all that much.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
