Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 178006B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 15:30:10 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r141so9503701wmg.4
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 12:30:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b203si13572974wmf.125.2017.01.30.12.30.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 12:30:08 -0800 (PST)
Date: Mon, 30 Jan 2017 20:30:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC V2 05/12] cpuset: Add cpuset_inc() inside cpuset_init()
Message-ID: <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-6-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170130033602.12275-6-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Mon, Jan 30, 2017 at 09:05:46AM +0530, Anshuman Khandual wrote:
> Currently cpusets_enabled() wrongfully returns 0 even if we have a root
> cpuset configured on the system. This got missed when jump level was
> introduced in place of number_of_cpusets with the commit 664eeddeef65
> ("mm: page_alloc: use jump labels to avoid checking number_of_cpusets")
> . This fixes the problem so that cpusets_enabled() returns positive even
> for the root cpuset.
> 
> Fixes: 664eeddeef65 ("mm: page_alloc: use jump labels to avoid")
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Superficially, this appears to always activate the cpuset_enabled
branch() when it doesn't really make sense that the root cpuset be
restricted. I strongly suspect it should be altered to cpuset_inc only
if the root cpuset is configured to isolate memory.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
