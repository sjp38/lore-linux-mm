Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07B9D6B0344
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 11:38:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t87so269645430pfk.4
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:38:45 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o22si6016216pgd.138.2017.03.23.08.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 08:38:44 -0700 (PDT)
Subject: Re: [PATCH v2 3/5] mm: use a dedicated workqueue for the free workers
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <1489568404-7817-4-git-send-email-aaron.lu@intel.com>
 <20170322063335.GF30149@bbox> <20170322084103.GC2360@aaronlu.sh.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4549498a-befc-133d-b204-dd69b191e579@intel.com>
Date: Thu, 23 Mar 2017 08:38:43 -0700
MIME-Version: 1.0
In-Reply-To: <20170322084103.GC2360@aaronlu.sh.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On 03/22/2017 01:41 AM, Aaron Lu wrote:
> On Wed, Mar 22, 2017 at 03:33:35PM +0900, Minchan Kim wrote:
>> On Wed, Mar 15, 2017 at 05:00:02PM +0800, Aaron Lu wrote:
>>> Introduce a workqueue for all the free workers so that user can fine
>>> tune how many workers can be active through sysfs interface: max_active.
>>> More workers will normally lead to better performance, but too many can
>>> cause severe lock contention.
>>
>> Let me ask a question.
>>
>> How well can workqueue distribute the jobs in multiple CPU?
> 
> I would say it's good enough for my needs.
> After all, it doesn't need many kworkers to achieve the 50% time
> decrease: 2-4 kworkers for EP and 4-8 kworkers for EX are enough from
> previous attched data.

It's also worth noting that we'd like to *also* like to look into
increasing how scalable freeing pages to a given zone is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
