Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A582B6B0008
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 06:47:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d40-v6so8854711pla.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 03:47:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w34-v6si860292pgk.596.2018.10.12.03.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 03:47:33 -0700 (PDT)
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <000000000000dc48d40577d4a587@google.com>
 <20181010151135.25766-1-mhocko@kernel.org>
 <201810110637.w9B6b9eH044188@www262.sakura.ne.jp>
Message-ID: <7bb967ec-81ae-2c07-7e58-9ad23167bb66@i-love.sakura.ne.jp>
Date: Fri, 12 Oct 2018 19:47:03 +0900
MIME-Version: 1.0
In-Reply-To: <201810110637.w9B6b9eH044188@www262.sakura.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, Michal Hocko <mhocko@suse.com>, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com

On 2018/10/11 15:37, Tetsuo Handa wrote:
> Michal Hocko wrote:
>> Once we are here, make sure that the reason to trigger the OOM is
>> printed without ratelimiting because this is really valuable to
>> debug what happened.
> 
> Here is my version.
> 

Hmm, per mem_cgroup flag would be better than per task_struct flag.
