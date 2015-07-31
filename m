Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 310DF6B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 14:00:27 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so37061708igb.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:00:27 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0223.hostedemail.com. [216.40.44.223])
        by mx.google.com with ESMTP id j3si4873996igx.35.2015.07.31.11.00.26
        for <linux-mm@kvack.org>;
        Fri, 31 Jul 2015 11:00:26 -0700 (PDT)
Message-ID: <1438365622.19675.97.camel@perches.com>
Subject: Re: [PATCH 14/15] mm: Drop unlikely before IS_ERR(_OR_NULL)
From: Joe Perches <joe@perches.com>
Date: Fri, 31 Jul 2015 11:00:22 -0700
In-Reply-To: <20150731110637.GB899@linux>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
	 <91586af267deb26b905fba61a9f1f665a204a4e3.1438331416.git.viresh.kumar@linaro.org>
	 <20150731085646.GA31544@node.dhcp.inet.fi>
	 <FA3D9AE9-9D1E-4232-87DE-42F21B408B24@gmail.com>
	 <20150731093450.GA7505@linux> <1438338481.19675.72.camel@perches.com>
	 <20150731110637.GB899@linux>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: yalin wang <yalin.wang2010@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linaro-kernel@lists.linaro.org, open list <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On Fri, 2015-07-31 at 16:36 +0530, Viresh Kumar wrote:
> On 31-07-15, 03:28, Joe Perches wrote:
> > If it's all fixed, then it's unlikely to be needed in checkpatch.
> 
> I thought checkpatch is more about not committing new mistakes, rather than
> finding them in old code.

True, but checkpatch is more about style than substance.

There are a lot of things that _could_ be added to the script
but don't have to be because of relative rarity.

The unanswered fundamental though is whether the unlikely use
in #define IS_ERR_VALUE is useful.

include/linux/err.h:21:#define IS_ERR_VALUE(x) unlikely((x) >= (unsigned long)-MAX_ERRNO)

How often does using unlikely here make the code smaller/faster
with more recent compilers than gcc 3.4?  Or even using gcc 3.4.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
