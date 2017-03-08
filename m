Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 854DF831CE
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 03:23:51 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o126so46571997pfb.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 00:23:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c17si2554984pgg.109.2017.03.08.00.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 00:23:50 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2889FOW007195
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 03:23:49 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 292cb9vr1j-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Mar 2017 03:23:49 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 8 Mar 2017 08:23:47 -0000
Date: Wed, 8 Mar 2017 09:23:40 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 1/4] s390: get rid of superfluous __GFP_REPEAT
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307154843.32516-2-mhocko@kernel.org>
Message-Id: <20170308082340.GB12158@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 04:48:40PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations.
> 
> page_table_alloc then uses the flag for a single page allocation. This
> means that this flag has never been actually useful here because it has
> always been used only for PAGE_ALLOC_COSTLY requests.
> 
> An earlier attempt to remove the flag 10d58bf297e2 ("s390: get rid of
> superfluous __GFP_REPEAT") has missed this one but the situation is very
> same here.
> 
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/s390/mm/pgalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

FWIW:
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

If you want, this can be routed via the s390 tree, whatever you prefer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
