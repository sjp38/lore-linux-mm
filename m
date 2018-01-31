Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5716B0006
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 02:58:56 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 79so10138611pge.16
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 23:58:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si1207609pgs.639.2018.01.30.23.58.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 23:58:55 -0800 (PST)
Date: Wed, 31 Jan 2018 08:58:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/migrate: Add new migration reason MR_HUGETLB
Message-ID: <20180131075852.GL21609@dhcp22.suse.cz>
References: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
 <20180130075949.GN21609@dhcp22.suse.cz>
 <b4bd6cda-a3b7-96dd-b634-d9b3670c1ecf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b4bd6cda-a3b7-96dd-b634-d9b3670c1ecf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Wed 31-01-18 07:55:05, Anshuman Khandual wrote:
> On 01/30/2018 01:29 PM, Michal Hocko wrote:
> > On Tue 30-01-18 08:37:14, Anshuman Khandual wrote:
> >> alloc_contig_range() initiates compaction and eventual migration for
> >> the purpose of either CMA or HugeTLB allocation. At present, reason
> >> code remains the same MR_CMA for either of those cases. Lets add a
> >> new reason code which will differentiate the purpose of migration
> >> as HugeTLB allocation instead.
> > Why do we need it?
> 
> The same reason why we have MR_CMA (maybe some other ones as well) at
> present, for reporting purpose through traces at the least. It just
> seemed like same reason code is being used for two different purpose
> of migration.

But do we have any real user asking for this kind of information?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
