Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 265376B0493
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:48:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k68so3296120wmd.14
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:48:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r1si12859217wrc.496.2017.07.26.04.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 04:48:20 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6QBiqPi059047
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:48:18 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bxpk2bvrv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:48:18 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 26 Jul 2017 12:48:16 +0100
Date: Wed, 26 Jul 2017 13:48:12 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm: take memory hotplug lock within
 numa_zonelist_order_handler()
References: <20170726111738.38768-1-heiko.carstens@de.ibm.com>
 <20170726113112.GJ2981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726113112.GJ2981@dhcp22.suse.cz>
Message-Id: <20170726114812.GH3218@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Andre Wild <wild@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Jul 26, 2017 at 01:31:12PM +0200, Michal Hocko wrote:
> On Wed 26-07-17 13:17:38, Heiko Carstens wrote:
> [...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6d30e914afb6..fc32aa81f359 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4891,9 +4891,11 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
> >  				NUMA_ZONELIST_ORDER_LEN);
> >  			user_zonelist_order = oldval;
> >  		} else if (oldval != user_zonelist_order) {
> > +			mem_hotplug_begin();
> >  			mutex_lock(&zonelists_mutex);
> >  			build_all_zonelists(NULL, NULL);
> >  			mutex_unlock(&zonelists_mutex);
> > +			mem_hotplug_done();
> >  		}
> >  	}
> >  out:
> 
> Please note that this code has been removed by
> http://lkml.kernel.org/r/20170721143915.14161-2-mhocko@kernel.org. It
> will get to linux-next as soon as Andrew releases a new version mmotm
> tree.

We still would need something for 4.13, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
