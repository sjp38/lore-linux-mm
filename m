Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB046B7E23
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 07:36:43 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d22-v6so7480046pfn.3
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 04:36:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d3-v6si8095999pgk.610.2018.09.07.04.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 04:36:42 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <20180806205121.GM10003@dhcp22.suse.cz>
 <0aeb76e1-558f-e38e-4c66-77be3ce56b34@I-love.SAKURA.ne.jp>
 <20180906113553.GR14951@dhcp22.suse.cz>
 <87b76eea-9881-724a-442a-c6079cbf1016@i-love.sakura.ne.jp>
 <20180906120508.GT14951@dhcp22.suse.cz>
 <37b763c1-b83e-1632-3187-55fb360a914e@i-love.sakura.ne.jp>
 <20180906135615.GA14951@dhcp22.suse.cz>
 <8dd6bc67-3f35-fdc6-a86a-cf8426608c75@i-love.sakura.ne.jp>
 <20180906141632.GB14951@dhcp22.suse.cz>
 <55a3fb37-3246-73d7-0f45-5835a3f4831c@i-love.sakura.ne.jp>
 <20180907111038.GH19621@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <4e1bcda7-ab40-3a79-f566-454e1f24c0ff@i-love.sakura.ne.jp>
Date: Fri, 7 Sep 2018 20:36:31 +0900
MIME-Version: 1.0
In-Reply-To: <20180907111038.GH19621@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On 2018/09/07 20:10, Michal Hocko wrote:
>> I can't waste my time in what you think the long term solution. Please
>> don't refuse/ignore my (or David's) patches without your counter
>> patches.
> 
> If you do not care about long term sanity of the code and if you do not
> care about a larger picture then I am not interested in any patches from
> you. MM code is far from trivial and no playground. This attitude of
> yours is just dangerous.
> 

Then, please explain how we guarantee that enough CPU resource is spent
between "exit_mmap() set MMF_OOM_SKIP" and "the OOM killer finds MMF_OOM_SKIP
was already set" so that last second allocation with high watermark can't fail
when 50% of available memory was already reclaimed.
