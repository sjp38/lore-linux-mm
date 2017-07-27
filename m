Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 686D16B04D5
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 17:42:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m80so9239290wmd.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:42:19 -0700 (PDT)
Received: from mail-wr0-x22c.google.com (mail-wr0-x22c.google.com. [2a00:1450:400c:c0c::22c])
        by mx.google.com with ESMTPS id g70si6172348wmc.80.2017.07.27.14.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 14:42:18 -0700 (PDT)
Received: by mail-wr0-x22c.google.com with SMTP id f21so92015444wrf.5
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:42:18 -0700 (PDT)
MIME-Version: 1.0
Reply-To: dmitriyz@waymo.com
In-Reply-To: <20170727125112.5c200880d7580525e24210e3@linux-foundation.org>
References: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
 <20170727164608.12701-1-dmitriyz@waymo.com> <20170727125112.5c200880d7580525e24210e3@linux-foundation.org>
From: Dima Zavin <dmitriyz@waymo.com>
Date: Thu, 27 Jul 2017 14:41:56 -0700
Message-ID: <CAPz4a6AP_OBSFAf6e-S7C+KwDVJj-CHbs5QHe+jJH_R1_1Gc7w@mail.gmail.com>
Subject: Re: [PATCH v2] cpuset: fix a deadlock due to incomplete patching of cpusets_enabled()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christopher Lameter <cl@linux.com>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>, Mel Gorman <mgorman@techsingularity.net>

On Thu, Jul 27, 2017 at 12:51 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 27 Jul 2017 09:46:08 -0700 Dima Zavin <dmitriyz@waymo.com> wrote:
>
>>  - Applied on top of v4.12 since one of the callers in page_alloc.c changed.
>>    Still only tested on v4.9.36 and compile tested against v4.12.
>
> That's a problem - this doesn't come close to applying on current
> mainline.  I can fix that I guess, but the result should be tested
> well.
>

I'll fix up for latest, and see if I can test it. I should be able to
boot vanilla with not too much trouble. May take a few days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
