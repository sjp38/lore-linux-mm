Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFA956B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 04:16:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 142-v6so10586977wmt.1
        for <linux-mm@kvack.org>; Tue, 29 May 2018 01:16:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12-v6si2749860edi.195.2018.05.29.01.16.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 May 2018 01:16:41 -0700 (PDT)
Date: Tue, 29 May 2018 10:16:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180529081639.GM27180@dhcp22.suse.cz>
References: <20180515091655.GD12670@dhcp22.suse.cz>
 <201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
 <20180518122045.GG21711@dhcp22.suse.cz>
 <201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
 <20180522061850.GB20020@dhcp22.suse.cz>
 <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
 <20180529071736.GI27180@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529071736.GI27180@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

With the full changelog. This can be either folded into the respective
patch or applied on top.
