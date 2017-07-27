Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 577996B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:52:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id w51so71324352qtc.12
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:52:45 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id k87si16500050qkh.369.2017.07.27.06.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 06:52:44 -0700 (PDT)
Received: by mail-qk0-x22b.google.com with SMTP id u139so41278226qka.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:52:44 -0700 (PDT)
Date: Thu, 27 Jul 2017 09:52:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] cgroup: revert fa06235b8eb0 ("cgroup: reset css on
 destruction")
Message-ID: <20170727135240.GE742618@devbig577.frc2.facebook.com>
References: <20170726083017.3yzeucmi7lcj46qd@esperanza>
 <20170727130428.28856-1-guro@fb.com>
 <20170727130428.28856-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727130428.28856-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 27, 2017 at 02:04:28PM +0100, Roman Gushchin wrote:
> Commit fa06235b8eb0 ("cgroup: reset css on destruction") caused
> css_reset callback to be called from the offlining path. Although
> it solves the problem mentioned in the commit description
> ("For instance, memory cgroup needs to reset memory.low, otherwise
> pages charged to a dead cgroup might never get reclaimed."),
> generally speaking, it's not correct.
> 
> An offline cgroup can still be a resource domain, and we shouldn't
> grant it more resources than it had before deletion.
> 
> For instance, if an offline memory cgroup has dirty pages, we should
> still imply i/o limits during writeback.
> 
> The css_reset callback is designed to return the cgroup state
> into the original state, that means reset all limits and counters.
> It's spomething different from the offlining, and we shouldn't use
> it from the offlining path. Instead, we should adjust necessary
> settings from the per-controller css_offline callbacks (e.g. reset
> memory.low).
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Tejun Heo <tj@kernel.org>

Please feel free to route with the previous patch through -mm.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
