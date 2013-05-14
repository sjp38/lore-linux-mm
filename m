Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 597406B0085
	for <linux-mm@kvack.org>; Tue, 14 May 2013 11:26:38 -0400 (EDT)
Date: Tue, 14 May 2013 16:26:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH 4/7] break out mapping "freepage" code
Message-ID: <20130514152635.GV11497@suse.de>
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
 <20130507212000.59652B69@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130507212000.59652B69@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On Tue, May 07, 2013 at 02:20:00PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> __remove_mapping() only deals with pages with mappings, meaning
> page cache and swap cache.
> 
> At this point, the page has been removed from the mapping's radix
> tree, and we need to ensure that any fs-specific (or swap-
> specific) resources are freed up.
> 
> We will be using this function from a second location in a
> following patch.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

I used up all my complaining about naming beans in the last patch and do
not have a better suggestion for the new helper so ...

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
