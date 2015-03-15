Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1968D900017
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 09:07:12 -0400 (EDT)
Received: by oiaz123 with SMTP id z123so18404475oia.3
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 06:07:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bq16si922905oec.2.2015.03.15.06.07.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 15 Mar 2015 06:07:11 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: Allow small allocations to fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
	<1426107294-21551-2-git-send-email-mhocko@suse.cz>
	<201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
	<20150315121317.GA30685@dhcp22.suse.cz>
In-Reply-To: <20150315121317.GA30685@dhcp22.suse.cz>
Message-Id: <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
Date: Sun, 15 Mar 2015 22:06:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sun 15-03-15 14:43:37, Tetsuo Handa wrote:
> [...]
> > If you want to count only those retries which involved OOM killer, you need
> > to do like
> > 
> > -			nr_retries++;
> > +			if (gfp_mask & __GFP_FS)
> > +				nr_retries++;
> > 
> > in this patch.
> 
> No, we shouldn't create another type of hidden NOFAIL allocation like
> this. I understand that the wording of the changelog might be confusing,
> though.
> 
> It says: "This implementation counts only those retries which involved
> OOM killer because we do not want to be too eager to fail the request."
> 
> Would it be more clear if I changed that to?
> "This implemetnation counts only those retries when the system is
> considered OOM because all previous reclaim attempts have resulted
> in no progress because we do not want to be too eager to fail the
> request."
> 
> We definitely _want_ to fail GFP_NOFS allocations.

I see. The updated changelog is much more clear.

> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
