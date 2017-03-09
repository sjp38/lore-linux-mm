Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A20886B0448
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 03:27:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id o126so101339253pfb.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 00:27:29 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n25si5742092pgd.378.2017.03.09.00.27.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 00:27:28 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v298EHEg066104
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 03:27:28 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 292f845s8y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Mar 2017 03:27:28 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Thu, 9 Mar 2017 08:27:24 -0000
Date: Thu, 9 Mar 2017 09:27:19 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 1/4] s390: get rid of superfluous __GFP_REPEAT
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-2-mhocko@kernel.org>
 <20170308082340.GB12158@osiris>
 <20170308141110.GL11028@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308141110.GL11028@dhcp22.suse.cz>
Message-Id: <20170309082719.GC9011@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 08, 2017 at 03:11:10PM +0100, Michal Hocko wrote:
> On Wed 08-03-17 09:23:40, Heiko Carstens wrote:
> > On Tue, Mar 07, 2017 at 04:48:40PM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> > > around 2.6.12 it has been ignored for low order allocations.
> > > 
> > > page_table_alloc then uses the flag for a single page allocation. This
> > > means that this flag has never been actually useful here because it has
> > > always been used only for PAGE_ALLOC_COSTLY requests.
> > > 
> > > An earlier attempt to remove the flag 10d58bf297e2 ("s390: get rid of
> > > superfluous __GFP_REPEAT") has missed this one but the situation is very
> > > same here.
> > > 
> > > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  arch/s390/mm/pgalloc.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > FWIW:
> > Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Thanks
> 
> > If you want, this can be routed via the s390 tree, whatever you prefer.
> 
> Yes, that would be great. I suspect the rest will take longer to get
> merged or land to a conclusion.

Ok, applied. Thanks! :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
