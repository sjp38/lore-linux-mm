Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id E78DD6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 10:50:46 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id w200so3053164ybe.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:50:46 -0700 (PDT)
Received: from mail-yb0-x233.google.com (mail-yb0-x233.google.com. [2607:f8b0:4002:c09::233])
        by mx.google.com with ESMTPS id g129si6609612ywd.483.2017.06.01.07.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 07:50:45 -0700 (PDT)
Received: by mail-yb0-x233.google.com with SMTP id 202so11379450ybd.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:50:45 -0700 (PDT)
Date: Thu, 1 Jun 2017 10:50:42 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170601145042.GA3494@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
 <20170524203616.GO24798@htj.duckdns.org>
 <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
 <20170524212745.GP24798@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524212745.GP24798@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

A short update.  I tried making root special while keeping the
existing threaded semantics but I didn't really like it because we
have to couple controller enables/disables with threaded
enables/disables.  I'm now trying a simpler, albeit a bit more
tedious, approach which should leave things mostly symmetrical.  I'm
hoping to be able to post mostly working patches this week.

Also, do you mind posting the debug patches as a separate series?
Let's get the bits which make sense indepdently in the tree.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
