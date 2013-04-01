Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A1A056B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 07:13:38 -0400 (EDT)
Date: Mon, 1 Apr 2013 14:13:24 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: mm: page_alloc: avoid marking zones full prematurely after
 zone_reclaim()
Message-ID: <20130401111324.GY18466@mwanda>
References: <20130327060141.GA23703@longonot.mountain>
 <20130327165556.GA22966@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130327165556.GA22966@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: mgorman@suse.de, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

I still don't understand the code in gfp_to_alloc_flags().

	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;

ORing with zero is odd.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
