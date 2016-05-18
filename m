Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 68B206B025E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:16:56 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so20347132lfd.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:16:56 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id qn6si8578378wjc.143.2016.05.18.00.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 00:16:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so10399005wmn.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:16:55 -0700 (PDT)
Date: Wed, 18 May 2016 09:16:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
Message-ID: <20160518071653.GA21654@dhcp22.suse.cz>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
 <20160426135752.GC20813@dhcp22.suse.cz>
 <20160517202856.GF12220@dhcp22.suse.cz>
 <20160517152139.fbda59b7c66e8470575050e8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517152139.fbda59b7c66e8470575050e8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue 17-05-16 15:21:39, Andrew Morton wrote:
> On Tue, 17 May 2016 22:28:56 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Andrew, this is not in the mmotm tree now because I didn't feel really
> > confortable with the patch without Oleg seeing it. But it seems Oleg is
> > ok [1] with it so could you push it to Linus along with the rest of oom
> > pile please?
> 
> Reluctant.  The CONFIG_COMPACTION=n regression which Joonsoo identified
> is quite severe.  Before patch: 10000 forks succeed.  After patch: 500
> forks fail.  Ouch.
> 
> How can we merge such a thing?

That regression has been fixed by
http://lkml.kernel.org/r/1463051677-29418-3-git-send-email-mhocko@kernel.org

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
