Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB572831F8
	for <linux-mm@kvack.org>; Fri, 19 May 2017 16:58:23 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w131so31675428qka.5
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:58:23 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id x37si9964607qth.131.2017.05.19.13.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 13:58:23 -0700 (PDT)
Received: by mail-qk0-x236.google.com with SMTP id u75so70760447qka.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:58:22 -0700 (PDT)
Date: Fri, 19 May 2017 16:58:20 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170519205820.GE15279@wtj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170519202624.GA15279@wtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Fri, May 19, 2017 at 04:26:24PM -0400, Tejun Heo wrote:
> (exactly in the way necessary), I wonder whether it'd be better to
> simply allow root to be both domain and thread root.

I'll give this approach a shot early next week.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
