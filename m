Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B1ACC82F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 15:44:01 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so264615144wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:44:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id du1si637845wib.20.2015.09.24.12.44.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 12:44:00 -0700 (PDT)
Date: Thu, 24 Sep 2015 15:43:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: remove pcp_counter_lock
Message-ID: <20150924194348.GA3009@cmpxchg.org>
References: <1442976106-49685-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442976106-49685-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 22, 2015 at 07:41:46PM -0700, Greg Thelen wrote:
> Commit 733a572e66d2 ("memcg: make mem_cgroup_read_{stat|event}() iterate
> possible cpus instead of online") removed the last use of the per memcg
> pcp_counter_lock but forgot to remove the variable.
> 
> Kill the vestigial variable.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
