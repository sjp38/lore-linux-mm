Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 032F86B025E
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 10:54:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so35028706wma.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 07:54:11 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id w6si1259054wjk.8.2016.07.20.07.54.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 07:54:10 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id i5so72752269wmg.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 07:54:10 -0700 (PDT)
Date: Wed, 20 Jul 2016 16:54:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
Message-ID: <20160720145405.GP11249@dhcp22.suse.cz>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Wed 20-07-16 20:11:09, Janani Ravichandran wrote:
> 
> > On Jul 11, 2016, at 8:03 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Mon 11-07-16 10:12:51, Rik van Riel wrote:
> >> 
> >> What mechanism do you have in mind for obtaining the name,
> >> Michal?
> > 
> > Not sure whether tracing infrastructure allows printk like %ps. If not
> > then it doesn't sound too hard to add.
> 
> It does allow %ps. Currently what is being printed is the function symbol 
> of the callback using %pF. Ia??d like to know why %pF is used instead of
> %ps in this case.

>From a quick look into the code %pF should be doing the same thing as
%ps in the end. Some architectures just need some magic to get a proper
address of the function.

> Michal, just to make sure I understand you correctly, do you mean that we
> could infer the names of the shrinkers by looking at the names of their callbacks?

Yes, %ps can then be used for the name of the shrinker structure
(assuming it is available).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
