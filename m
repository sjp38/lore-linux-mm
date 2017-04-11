Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9F96B039F
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:26:42 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id a21so130414756oic.5
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 06:26:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z13si7840204otd.215.2017.04.11.06.26.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 06:26:41 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
	<20170411071552.GA6729@dhcp22.suse.cz>
	<201704112043.EBD39096.JtFLQHVOFOFMOS@I-love.SAKURA.ne.jp>
	<20170411115428.GI6729@dhcp22.suse.cz>
In-Reply-To: <20170411115428.GI6729@dhcp22.suse.cz>
Message-Id: <201704112226.EGF30796.FLFMJHOQtVFSOO@I-love.SAKURA.ne.jp>
Date: Tue, 11 Apr 2017 22:26:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

Michal Hocko wrote:
> This repeating of "hypotetical" demand of tunable is getting boring. I
> would really appreciate to see at least _one_ such report from the
> field. If you do not have any please stop wasting others people time by
> unfounded claims.

I'm talking from my experiences at a support center in Japan. But I can't
share such report with you because I left two years ago and I can no longer
ask customers for permission. Therefore, this is a catch-22 problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
