Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD7406B000D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 18:25:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d40-v6so1435086pla.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 15:25:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a13-v6si24696811pgj.495.2018.08.15.15.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 15:25:12 -0700 (PDT)
Date: Wed, 15 Aug 2018 15:25:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 0/2] Directed kmem charging
Message-Id: <20180815152511.3ea63aa54c5fac0bfe9370da@linux-foundation.org>
In-Reply-To: <20180627191250.209150-1-shakeelb@google.com>
References: <20180627191250.209150-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Amir Goldstein <amir73il@gmail.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Jun 2018 12:12:48 -0700 Shakeel Butt <shakeelb@google.com> wrote:

> The Linux kernel's memory cgroup allows limiting the memory usage of
> the jobs running on the system to provide isolation between the jobs.
> All the kernel memory allocated in the context of the job and marked
> with __GFP_ACCOUNT will also be included in the memory usage and be
> limited by the job's limit.
> 
> The kernel memory can only be charged to the memcg of the process in
> whose context kernel memory was allocated. However there are cases where
> the allocated kernel memory should be charged to the memcg different
> from the current processes's memcg. This patch series contains two such
> concrete use-cases i.e. fsnotify and buffer_head.
> 
> The fsnotify event objects can consume a lot of system memory for large
> or unlimited queues if there is either no or slow listener. The events
> are allocated in the context of the event producer. However they should
> be charged to the event consumer. Similarly the buffer_head objects can
> be allocated in a memcg different from the memcg of the page for which
> buffer_head objects are being allocated.
> 
> To solve this issue, this patch series introduces mechanism to charge
> kernel memory to a given memcg. In case of fsnotify events, the memcg of
> the consumer can be used for charging and for buffer_head, the memcg of
> the page can be charged. For directed charging, the caller can use the
> scope API memalloc_[un]use_memcg() to specify the memcg to charge for
> all the __GFP_ACCOUNT allocations within the scope.

This patchset is not showing signs of having been well reviewed at
this time.  Could people please take another look?
