Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF6906B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:41:02 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j28so4041018wrd.17
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:41:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m200si13578wma.106.2018.03.08.15.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 15:41:01 -0800 (PST)
Date: Thu, 8 Mar 2018 15:40:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memcg: expose mem_cgroup_put API
Message-Id: <20180308154058.9158c9c1ff1e4e67990bcce7@linux-foundation.org>
In-Reply-To: <20180308024850.39737-1-shakeelb@google.com>
References: <20180308024850.39737-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed,  7 Mar 2018 18:48:50 -0800 Shakeel Butt <shakeelb@google.com> wrote:

> This patch exports mem_cgroup_put API to put the refcnt of the memory
> cgroup.

Not the best of changelogs :(

Why is this patch being added?

It's a prerequisite for <I-forget-which-patch> isn't it?
