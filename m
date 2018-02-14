Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED926B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 04:59:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b6so1666214pgu.16
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 01:59:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l63-v6si8764547plb.565.2018.02.14.01.59.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Feb 2018 01:59:14 -0800 (PST)
Date: Wed, 14 Feb 2018 10:59:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
Message-ID: <20180214095911.GB28460@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Mon 12-02-18 16:24:25, David Rientjes wrote:
> Both kernelcore= and movablecore= can be used to define the amount of
> ZONE_NORMAL and ZONE_MOVABLE on a system, respectively.  This requires
> the system memory capacity to be known when specifying the command line,
> however.
> 
> This introduces the ability to define both kernelcore= and movablecore=
> as a percentage of total system memory.  This is convenient for systems
> software that wants to define the amount of ZONE_MOVABLE, for example, as
> a proportion of a system's memory rather than a hardcoded byte value.
> 
> To define the percentage, the final character of the parameter should be
> a '%'.

I do not have any objections regarding the extension. What I am more
interested in is _why_ people are still using this command line
parameter at all these days. Why would anybody want to introduce lowmem
issues from 32b days. I can see the CMA/Hotplug usecases for
ZONE_MOVABLE but those have their own ways to define zone movable. I was
tempted to simply remove the kernelcore already. Could you be more
specific what is your usecase which triggered a need of an easier
scaling of the size?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
