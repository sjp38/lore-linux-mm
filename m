Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7F356B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 16:31:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 8so56779410pgc.12
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 13:31:21 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id q12si6301426pgr.237.2017.06.04.13.31.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 13:31:20 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id n23so73539717pfb.2
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 13:31:20 -0700 (PDT)
Date: Sun, 4 Jun 2017 13:31:16 -0700
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v2] memcg: refactor mem_cgroup_resize_limit()
Message-ID: <20170604203116.GA19053@google.com>
References: <20170601230212.30578-1-yuzhao@google.com>
 <20170604200437.17815-1-yuzhao@google.com>
 <20170604200942.GA23523@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170604200942.GA23523@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, n.borisov.lkml@gmail.com

On Sun, Jun 04, 2017 at 11:09:42PM +0300, Vladimir Davydov wrote:
> On Sun, Jun 04, 2017 at 01:04:37PM -0700, Yu Zhao wrote:
> > @@ -2498,22 +2449,24 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> >  		}
> >  
> >  		mutex_lock(&memcg_limit_mutex);
> > -		if (limit < memcg->memory.limit) {
> > +		inverted = memsw ? limit < memcg->memory.limit :
> > +				   limit > memcg->memsw.limit;
> > +		if (inverted)
> >  			mutex_unlock(&memcg_limit_mutex);
> >  			ret = -EINVAL;
> >  			break;
> >  		}
> 
> For some reason, I liked this patch more without this extra variable :-)
Well, I'll refrain myself from commenting more because we are now at
the risk of starting a coding style war over this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
