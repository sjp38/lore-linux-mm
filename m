Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB4226B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:08:29 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so156098537lfe.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:08:29 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id w127si7473763wma.80.2016.08.04.23.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 23:47:50 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 939FB1C1786
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 07:47:49 +0100 (IST)
Date: Fri, 5 Aug 2016 07:47:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH V2 1/2] mm/page_alloc: Replace set_dma_reserve to
 set_memory_reserve
Message-ID: <20160805064747.GN2799@techsingularity.net>
References: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Aug 04, 2016 at 10:42:08PM +0530, Srikar Dronamraju wrote:
> Expand the scope of the existing dma_reserve to accommodate other memory
> reserves too. Accordingly rename variable dma_reserve to
> nr_memory_reserve.
> 
> set_memory_reserve also takes a new parameter that helps to identify if
> the current value needs to be incremented.
> 

I think the parameter is ugly and it should have been just
inc_memory_reserve but at least it works.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
