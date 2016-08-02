Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13D446B0261
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 09:22:12 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m130so375611397ioa.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 06:22:12 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0128.outbound.protection.outlook.com. [104.47.1.128])
        by mx.google.com with ESMTPS id t35si1658106otd.11.2016.08.02.06.22.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 06:22:11 -0700 (PDT)
Date: Tue, 2 Aug 2016 16:22:00 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160802132200.GE13263@esperanza>
References: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
 <20160802124231.GJ12403@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160802124231.GJ12403@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 02:42:32PM +0200, Michal Hocko wrote:
> 
> On Mon 01-08-16 16:26:24, Vladimir Davydov wrote:
> [...]
> > +static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> > +{
> > +	while (!atomic_inc_not_zero(&memcg->id.ref))
> > +		memcg = parent_mem_cgroup(memcg);
> > +	return memcg;
> > +}
> 
> Does this actually work properly? Say we have root -> A so parent is
> NULL if root (use_hierarchy == false).

Yeah, I completely forgot about the !use_hierarchy case. Thanks for
catching this. I'll fix and resend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
