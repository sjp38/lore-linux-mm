Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id B330C6B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:05:30 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id b68so122145177ywe.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:05:30 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id c68si8529545ywe.424.2017.05.24.10.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 10:05:29 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id 17so13199506ywk.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:05:29 -0700 (PDT)
Date: Wed, 24 May 2017 13:05:27 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 12/17] cgroup: Remove cgroup v2 no internal
 process constraint
Message-ID: <20170524170527.GH24798@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-13-git-send-email-longman@redhat.com>
 <20170519203824.GC15279@wtj.duckdns.org>
 <93a69664-4ba6-9ee8-e4ea-ce76b6682c77@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <93a69664-4ba6-9ee8-e4ea-ce76b6682c77@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Mon, May 22, 2017 at 12:56:08PM -0400, Waiman Long wrote:
> All controllers can use the special sub-directory if userland chooses to
> do so. The problem that I am trying to address in this patch is to allow
> more natural hierarchy that reflect a certain purpose, like the task
> classification done by systemd. Restricting tasks only to leaf nodes
> makes the hierarchy unnatural and probably difficult to manage.

I see but how is this different from userland just creating the leaf
cgroup?  I'm not sure what this actually enables in terms of what can
be achieved with cgroup.  I suppose we can argue that this is more
convenient but I'd like to keep the interface orthogonal as much as
reasonably possible.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
