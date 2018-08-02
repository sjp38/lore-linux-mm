Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92FE86B0005
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 06:44:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so662726edi.20
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 03:44:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g34-v6si2315909edd.226.2018.08.02.03.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 03:44:04 -0700 (PDT)
Date: Thu, 2 Aug 2018 12:44:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-ID: <20180802104401.GF10808@dhcp22.suse.cz>
References: <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
 <20180802085043.GC10808@dhcp22.suse.cz>
 <20180802092549.hooadz5e6tizns3z@salvia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180802092549.hooadz5e6tizns3z@salvia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Georgi Nikolov <gnikolov@icdsoft.com>, Vlastimil Babka <vbabka@suse.cz>, Florian Westphal <fw@strlen.de>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On Thu 02-08-18 11:25:49, Pablo Neira Ayuso wrote:
> On Thu, Aug 02, 2018 at 10:50:43AM +0200, Michal Hocko wrote:
[...]
> > diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> > index d0d8397c9588..b769408e04ab 100644
> > --- a/net/netfilter/x_tables.c
> > +++ b/net/netfilter/x_tables.c
> > @@ -1178,12 +1178,7 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
> >  	if (sz < sizeof(*info) || sz >= XT_MAX_TABLE_SIZE)
> >  		return NULL;
> >  
> > -	/* __GFP_NORETRY is not fully supported by kvmalloc but it should
> > -	 * work reasonably well if sz is too large and bail out rather
> > -	 * than shoot all processes down before realizing there is nothing
> > -	 * more to reclaim.
> > -	 */
> > -	info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
> > +	info = kvmalloc(sz, GFP_KERNEL | __GFP_ACCOUNT);
> 
> I guess the large number of cgroups match is helping to consume a lot
> of memory very quickly? We have a PATH_MAX in struct xt_cgroup_info_v1.

I really fail to see how that is related to the patch here.
-- 
Michal Hocko
SUSE Labs
