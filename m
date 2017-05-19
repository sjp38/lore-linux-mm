Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2C628041F
	for <linux-mm@kvack.org>; Fri, 19 May 2017 08:47:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j27so5009979wre.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 05:47:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b17si9418179edh.295.2017.05.19.05.47.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 05:47:03 -0700 (PDT)
Date: Fri, 19 May 2017 14:47:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] fix premature OOM killer
Message-ID: <20170519124702.GE29839@dhcp22.suse.cz>
References: <20170519112604.29090-1-mhocko@kernel.org>
 <201705192037.FAG43296.QOLOMOFJFtVSHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201705192037.FAG43296.QOLOMOFJFtVSHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 19-05-17 20:37:21, Tetsuo Handa wrote:
> and patch 2 is wrong.

Why?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
