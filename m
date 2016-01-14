Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id CB29A828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 15:25:56 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so450765361wmf.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 12:25:56 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m12si39611387wmg.59.2016.01.14.12.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 12:25:55 -0800 (PST)
Date: Thu, 14 Jan 2016 15:25:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: basic memory statistics in cgroup2
 memory controller
Message-ID: <20160114202521.GB20218@cmpxchg.org>
References: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
 <1452722469-24704-2-git-send-email-hannes@cmpxchg.org>
 <20160113144930.b20ed63f1c6a28730f66eccd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160113144930.b20ed63f1c6a28730f66eccd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jan 13, 2016 at 02:49:30PM -0800, Andrew Morton wrote:
> > @@ -5095,6 +5107,46 @@ static int memory_events_show(struct seq_file *m, void *v)
> >  	return 0;
> >  }
> >  
> > +static int memory_stat_show(struct seq_file *m, void *v)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> > +	int i;
> > +
> > +	/* Memory consumer totals */
> > +
> > +	seq_printf(m, "anon %lu\n",
> > +		   tree_stat(memcg, MEM_CGROUP_STAT_RSS) * PAGE_SIZE);
> 
> Is there any reason why this won't overflow a longword on 32-bit?

It will, I don't know what I was thinking there. Fixed in the update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
