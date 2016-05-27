Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDF36B0253
	for <linux-mm@kvack.org>; Fri, 27 May 2016 10:52:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a136so62329957wme.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:52:17 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id gq6si26454189wjb.181.2016.05.27.07.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 07:52:16 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id a136so76624309wme.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:52:16 -0700 (PDT)
Date: Fri, 27 May 2016 16:52:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160527145215.GS27686@dhcp22.suse.cz>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
 <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
 <20160527142626.GQ27686@dhcp22.suse.cz>
 <20160527144549.GC26059@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527144549.GC26059@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 17:45:49, Vladimir Davydov wrote:
> On Fri, May 27, 2016 at 04:26:26PM +0200, Michal Hocko wrote:
[...]
> > I am doing quite large changes in this area and this would cause many
> > conflicts. Do you think you can postpone this after my patchset [1] gets
> > sorted out please?
> 
> I'm fine with it.

Thanks!
 
> > I haven't looked at the patch carefully so I cannot tell much about it
> > right now but just wanted to give a heads up for the conflicts.
> 
> I'd appreciate if you could take a look at this patch once time permits.

Sure, I will try next week. It's been a long week and the brain is in
the weekend mode already...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
