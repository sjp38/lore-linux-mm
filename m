Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 851556B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:06:42 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so40935124pdb.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 04:06:42 -0700 (PDT)
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com. [209.85.192.173])
        by mx.google.com with ESMTPS id dv12si9719084pdb.19.2015.07.31.04.06.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 04:06:41 -0700 (PDT)
Received: by pdbbh15 with SMTP id bh15so40934943pdb.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 04:06:41 -0700 (PDT)
Date: Fri, 31 Jul 2015 16:36:37 +0530
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH 14/15] mm: Drop unlikely before IS_ERR(_OR_NULL)
Message-ID: <20150731110637.GB899@linux>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
 <91586af267deb26b905fba61a9f1f665a204a4e3.1438331416.git.viresh.kumar@linaro.org>
 <20150731085646.GA31544@node.dhcp.inet.fi>
 <FA3D9AE9-9D1E-4232-87DE-42F21B408B24@gmail.com>
 <20150731093450.GA7505@linux>
 <1438338481.19675.72.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438338481.19675.72.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: yalin wang <yalin.wang2010@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linaro-kernel@lists.linaro.org, open list <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On 31-07-15, 03:28, Joe Perches wrote:
> If it's all fixed, then it's unlikely to be needed in checkpatch.

I thought checkpatch is more about not committing new mistakes, rather than
finding them in old code.

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
