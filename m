Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 29BF46B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 07:34:49 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so75050554wid.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 04:34:48 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id u1si4332955wia.61.2015.08.27.04.34.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 04:34:47 -0700 (PDT)
Received: by wicgk12 with SMTP id gk12so6267018wic.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 04:34:46 -0700 (PDT)
Date: Thu, 27 Aug 2015 13:34:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150827113444.GB27052@dhcp22.suse.cz>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
 <201508270003.FCD17618.FFVOFJHOQMSOtL@I-love.SAKURA.ne.jp>
 <20150827084045.GD14367@dhcp22.suse.cz>
 <201508272011.ABJ26077.OOLJOtFHVQFFMS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508272011.ABJ26077.OOLJOtFHVQFFMS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 27-08-15 20:11:24, Tetsuo Handa wrote:
> Cc: stable <stable@vger.kernel.org> [4.0+]

Please also add
Fixes: 83363b917a29 ("oom: make sure that TIF_MEMDIE is set under
task_lock")
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
