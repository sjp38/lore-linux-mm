Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7691E6B0038
	for <linux-mm@kvack.org>; Sat,  1 Aug 2015 07:18:28 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so54321482pdb.1
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 04:18:28 -0700 (PDT)
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com. [209.85.220.47])
        by mx.google.com with ESMTPS id sn7si2850976pbc.78.2015.08.01.04.18.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Aug 2015 04:18:27 -0700 (PDT)
Received: by pacan13 with SMTP id an13so56605894pac.1
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 04:18:27 -0700 (PDT)
Date: Sat, 1 Aug 2015 16:48:21 +0530
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH 14/15] mm: Drop unlikely before IS_ERR(_OR_NULL)
Message-ID: <20150801111821.GJ899@linux>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
 <91586af267deb26b905fba61a9f1f665a204a4e3.1438331416.git.viresh.kumar@linaro.org>
 <20150731085646.GA31544@node.dhcp.inet.fi>
 <FA3D9AE9-9D1E-4232-87DE-42F21B408B24@gmail.com>
 <20150731093450.GA7505@linux>
 <1438338481.19675.72.camel@perches.com>
 <20150731110637.GB899@linux>
 <1438365622.19675.97.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438365622.19675.97.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: yalin wang <yalin.wang2010@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linaro-kernel@lists.linaro.org, open list <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On 31-07-15, 11:00, Joe Perches wrote:
> On Fri, 2015-07-31 at 16:36 +0530, Viresh Kumar wrote:
> > On 31-07-15, 03:28, Joe Perches wrote:
> > > If it's all fixed, then it's unlikely to be needed in checkpatch.
> > 
> > I thought checkpatch is more about not committing new mistakes, rather than
> > finding them in old code.
> 
> True, but checkpatch is more about style than substance.
> 
> There are a lot of things that _could_ be added to the script
> but don't have to be because of relative rarity.
> 
> The unanswered fundamental though is whether the unlikely use
> in #define IS_ERR_VALUE is useful.
> 
> include/linux/err.h:21:#define IS_ERR_VALUE(x) unlikely((x) >= (unsigned long)-MAX_ERRNO)
> 
> How often does using unlikely here make the code smaller/faster
> with more recent compilers than gcc 3.4?  Or even using gcc 3.4.

No idea :)


-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
