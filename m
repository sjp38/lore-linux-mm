Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8D7440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 09:01:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b11so9106662wmh.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 06:01:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v17si418250wrc.379.2017.07.14.06.01.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 06:01:13 -0700 (PDT)
Date: Fri, 14 Jul 2017 14:01:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/9] mm, page_alloc: rip out ZONELIST_ORDER_ZONE
Message-ID: <20170714130111.vwnddyuypd2lcyu4@suse.de>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-2-mhocko@kernel.org>
 <20170714093650.l67vbem2g4typkta@suse.de>
 <20170714104756.GD2618@dhcp22.suse.cz>
 <20170714111633.gk5rpu2d5ghkbrrd@suse.de>
 <20170714113840.GI2618@dhcp22.suse.cz>
 <20170714125616.clbp4ezgtoon6cmk@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170714125616.clbp4ezgtoon6cmk@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri, Jul 14, 2017 at 01:56:16PM +0100, Mel Gorman wrote:
> >  	if (!write) {
> > -		int len = sizeof("Default");
> > -		if (copy_to_user(buffer, "Default", len))
> > +		int len = sizeof("Node");
> > +		if (copy_to_user(buffer, "Node", len))
> >  			return -EFAULT;
> 
> Ok for the name. But what's with using sizeof?

Bah, sizeof static compile-time string versus char *. Never mind.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
