Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE0D28041F
	for <linux-mm@kvack.org>; Fri, 19 May 2017 07:37:40 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 206so42373546iob.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:37:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i83si8736431iof.53.2017.05.19.04.37.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 04:37:39 -0700 (PDT)
Subject: Re: [PATCH 0/2] fix premature OOM killer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170519112604.29090-1-mhocko@kernel.org>
In-Reply-To: <20170519112604.29090-1-mhocko@kernel.org>
Message-Id: <201705192037.FAG43296.QOLOMOFJFtVSHF@I-love.SAKURA.ne.jp>
Date: Fri, 19 May 2017 20:37:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Hi,
> this is a follow up for [1]. The first patch is what Tetsuo suggested
> [2], I've just added a changelog for it. This one should be merged
> as soon as possible. The second patch is still an RFC. I _believe_
> that it is the right thing to do but I haven't checked all the PF paths
> which return VM_FAULT_OOM to be sure that there is nobody who would return
> this error when not doing a real allocation.
> 
> [1] http://lkml.kernel.org/r/1495034780-9520-1-git-send-email-guro@fb.com
> [2] http://lkml.kernel.org/r/201705182257.HJJ52185.OQStFLFMHVOJOF@I-love.SAKURA.ne.jp
> 
> 

Patch 1 is insufficient and patch 2 is wrong. Please wait. I'm writing patch 1 now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
