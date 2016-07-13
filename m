Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4AD6B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 15:12:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so40793888wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 12:12:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l184si2525453wmg.12.2016.07.13.12.12.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 12:12:34 -0700 (PDT)
Subject: Re: [PATCH 3/3] Add name fields in shrinker tracepoint definitions
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <6114f72a15d5e52984ea546ba977737221351636.1468051282.git.janani.rvchndrn@gmail.com>
 <447d8214-3c3d-cc4a-2eff-a47923fbe45f@suse.cz>
 <ed4c8fa0-d727-c014-58c5-efe3a191f2ec@suse.de>
 <010E7991-C436-414A-8F5A-602705E5A47B@gmail.com>
From: Tony Jones <tonyj@suse.de>
Message-ID: <3261aa0c-92d0-dfb8-e1ca-7c518d2a02c1@suse.de>
Date: Wed, 13 Jul 2016 12:12:28 -0700
MIME-Version: 1.0
In-Reply-To: <010E7991-C436-414A-8F5A-602705E5A47B@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/12/2016 11:16 PM, Janani Ravichandran wrote:
>> I also have a patch which adds a similar latency script (python) but interfaces it into the perf script setup.
> 
> I?m looking for pointers for writing latency scripts using tracepoints as I?m new to it. Can I have a look at yours, please?

I was going to send it to you (off list email) last night but I seem to have misplaced the latest version.  I think it's on a diff test system.  I'll fire it off to you when I find it, hopefully in the next couple of days. I can also post it here if there is any interest.  I'd like to see it added to the builtin scripts under tools/perf.

tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
