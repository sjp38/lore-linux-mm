Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2926B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:18:24 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l68so27177538wml.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:18:24 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id dz12si3695141wjb.180.2016.03.08.05.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 05:18:23 -0800 (PST)
Received: by mail-wm0-f54.google.com with SMTP id l68so27176999wml.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:18:23 -0800 (PST)
Date: Tue, 8 Mar 2016 14:18:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm 0/2] oom_reaper: missing parts
Message-ID: <20160308131820.GE13542@dhcp22.suse.cz>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 08-03-16 14:12:15, Michal Hocko wrote:
> Hi Andrew,
> there are two following left overs which are missing in your tree
> right now. Could you add them please?
> 
> Thanks to Tetsuo for pointing it out http://lkml.kernel.org/r/201603082010.EEE43272.QVJFOFOHtMSLOF@I-love.SAKURA.ne.jp

And I failed to notice this was a private email.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
