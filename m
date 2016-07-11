Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2789B6B0261
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:33:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so54188765wma.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:33:46 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 72si15420799wmh.117.2016.07.11.07.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 07:33:45 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w75so15935859wmd.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:33:45 -0700 (PDT)
Date: Mon, 11 Jul 2016 16:33:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
Message-ID: <20160711143342.GN1811@dhcp22.suse.cz>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468246371.13253.63.camel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Mon 11-07-16 10:12:51, Rik van Riel wrote:
> On Mon, 2016-07-11 at 08:37 +0200, Michal Hocko wrote:
> > On Sat 09-07-16 04:43:31, Janani Ravichandran wrote:
> > > Struct shrinker does not have a field to uniquely identify the
> > > shrinkers
> > > it represents. It would be helpful to have a new field to hold
> > > names of
> > > shrinkers. This information would be useful while analyzing their
> > > behavior using tracepoints.
> > 
> > This will however increase the vmlinux size even when no tracing is
> > enabled. Why cannot we simply print the name of the shrinker
> > callbacks?
> 
> What mechanism do you have in mind for obtaining the name,
> Michal?

Not sure whether tracing infrastructure allows printk like %ps. If not
then it doesn't sound too hard to add.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
