Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 743806B0263
	for <linux-mm@kvack.org>; Thu, 12 May 2016 12:38:28 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j8so56003785lfd.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 09:38:28 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id j80si46548061wmj.57.2016.05.12.09.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 09:38:27 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so16895542wmn.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 09:38:27 -0700 (PDT)
Date: Thu, 12 May 2016 18:38:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20160512163824.GA4940@dhcp22.suse.cz>
References: <004b01d1a9d1$3817fc10$a847f430$@alibaba-inc.com>
 <006e01d1a9d8$5c7a15f0$156e41d0$@alibaba-inc.com>
 <201605130009.EAJ35441.JLtFVOHFOSOMQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605130009.EAJ35441.JLtFVOHFOSOMQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hillf.zj@alibaba-inc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 13-05-16 00:09:07, Tetsuo Handa wrote:
[...]
> Michal, this version eliminated overhead of walking the process list
> when nothing is wrong. You are aware of the possibility of
> debug_show_all_locks() failing to report the culprit, aren't you?
> So, what are unacceptable major problems for you?

I do not remember complaining about anything unacceptable for this
patch. I just thought it was way too large the last time I have looked
at it. Johannes was suggesting to simply extend warn_alloc_failed to
also report too many retries with some extended information as a more
lightweight approach.  It wouldn't give as much information as your
watchdog but maybe it would be sufficient to figure out that something
really bad is going on. Dunno but I would rather see a more lightweight
debugging aid than a lot of code which sit basically unused most of the
time.

That being said I cannot comment on this particular version as I haven't
checked it properly yet.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
