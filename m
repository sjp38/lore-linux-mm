Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id AD2876B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 05:55:38 -0400 (EDT)
Date: Tue, 2 Apr 2013 11:55:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm: page_alloc: avoid marking zones full prematurely after
 zone_reclaim()
Message-ID: <20130402095536.GG24345@dhcp22.suse.cz>
References: <20130327060141.GA23703@longonot.mountain>
 <20130327165556.GA22966@dhcp22.suse.cz>
 <20130401111324.GY18466@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130401111324.GY18466@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: mgorman@suse.de, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon 01-04-13 14:13:24, Dan Carpenter wrote:
> I still don't understand the code in gfp_to_alloc_flags().
> 
> 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> 
> ORing with zero is odd.

It is a named zero ;) Something similar like GFP_NOWAIT AFAIU.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
