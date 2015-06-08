Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 37E856B006E
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:36:11 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so66069501pdj.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:36:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z5si3908652pdk.254.2015.06.08.05.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:36:10 -0700 (PDT)
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is configured
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
	<alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
	<20150605111302.GB26113@dhcp22.suse.cz>
	<201506061551.BHH48489.QHFOMtFLSOFOJV@I-love.SAKURA.ne.jp>
	<20150608082137.GD1380@dhcp22.suse.cz>
In-Reply-To: <20150608082137.GD1380@dhcp22.suse.cz>
Message-Id: <201506082053.IIF18706.JFFFHOQtMLOSVO@I-love.SAKURA.ne.jp>
Date: Mon, 8 Jun 2015 20:53:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 06-06-15 15:51:35, Tetsuo Handa wrote:
> > For me, !__GFP_FS allocations not calling out_of_memory() _forever_ is a
> > violation of the user policy.
> 
> Yes, the current behavior of GFP_NOFS is highly suboptimal, but this has
> _nothing_ what so ever to do with this patch and panic_on_oom handling.
> The former one is the page allocator proper while we are in the OOM
> killer layer here.
> 
> This is not the first time you have done that. Please stop it. It makes
> a complete mess of the original discussions.

My specific area of expertise in Linux kernel is security/tomoyo/ directory.
What I could contribute with other areas is to pay attention to potential
possibilities. But I'm such outsider about other areas that I can't
differentiate the page allocator proper from the OOM killer layer.

Excuse me for focusing on the wrong issue, but I will likely unconsciously
make the same mistake again. Please ignore or point out when I made mistakes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
