Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D10616B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 07:26:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i4so14689585wmg.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:26:23 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id c127si667277wmd.112.2016.07.07.04.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 04:26:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 02FE11C2FF1
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:26:22 +0100 (IST)
Date: Thu, 7 Jul 2016 12:26:20 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 31/31] mm, vmstat: Remove zone and node double accounting
 by approximating retries
Message-ID: <20160707112620.GV11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-32-git-send-email-mgorman@techsingularity.net>
 <577D4A24.1090800@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <577D4A24.1090800@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 06, 2016 at 11:12:52AM -0700, Dave Hansen wrote:
> On 07/01/2016 01:01 PM, Mel Gorman wrote:
> > +#ifdef CONFIG_HIGHMEM
> > +extern unsigned long highmem_file_pages;
> > +
> > +static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
> > +							int nr_pages)
> > +{
> > +	if (is_highmem_idx(zid) && is_file_lru(lru))
> > +		highmem_file_pages += nr_pages;
> > +}
> > +#else
> 
> Shouldn't highmem_file_pages technically be an atomic_t (or atomic64_t)?
>  We could have highmem on two nodes which take two different LRU locks.

It would require a NUMA machine with highmem or very weird
configurations but sure, atomic is safer.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
