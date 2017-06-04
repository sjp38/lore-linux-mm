Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD066B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 15:26:01 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b65so9275325lfh.8
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:26:01 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id p129si3183894lfp.49.2017.06.04.12.25.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 12:25:59 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id f14so8140557lfe.1
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:25:58 -0700 (PDT)
Date: Sun, 4 Jun 2017 22:25:54 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [RFC PATCH v2 1/7] mm, oom: refactor select_bad_process() to
 take memcg as an argument
Message-ID: <20170604192553.GA19980@esperanza>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <1496342115-3974-2-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496342115-3974-2-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 01, 2017 at 07:35:09PM +0100, Roman Gushchin wrote:
> The select_bad_process() function will be used further
> to select a process to kill in the victim cgroup.
> This cgroup doesn't necessary match oc->memcg,
> which is a cgroup, which limits were caused cgroup-wide OOM
> (or NULL in case of global OOM).
> 
> So, refactor select_bad_process() to take a pointer to
> a cgroup to iterate over as an argument.

IMHO this patch, as well as patches 2-5, doesn't deserve to be submitted
separately: none of them make sense as a separate change; worse, patches
4 and 5 introduce user API that doesn't do anything without patch 6. All
of the changes are relatively small and singling them out doesn't really
facilitate review, so I'd merge them all in patch 6.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
