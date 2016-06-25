Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBC776B0005
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 13:29:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so96101899lfg.2
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 10:29:56 -0700 (PDT)
Received: from mail.sig21.net (mail.sig21.net. [80.244.240.74])
        by mx.google.com with ESMTPS id w123si2859872wmd.120.2016.06.25.10.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Jun 2016 10:29:55 -0700 (PDT)
Date: Sat, 25 Jun 2016 19:29:51 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: 4.6.2 frequent crashes under memory + IO pressure
Message-ID: <20160625172951.GA5586@sig21.net>
References: <20160616212641.GA3308@sig21.net>
 <c9c87635-6e00-5ce7-b05a-966011c8fe3f@I-love.SAKURA.ne.jp>
 <20160623091830.GA32535@sig21.net>
 <201606232026.GFJ26539.QVtFFOJOOLHFMS@I-love.SAKURA.ne.jp>
 <20160625155006.GA4166@sig21.net>
 <201606260204.BDB48978.FSFFJQHOMLVOtO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606260204.BDB48978.FSFFJQHOMLVOtO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org

On Sun, Jun 26, 2016 at 02:04:40AM +0900, Tetsuo Handa wrote:
> It seems to me that somebody is using ALLOC_NO_WATERMARKS (with possibly
> __GFP_NOWARN), but I don't know how to identify such callers. Maybe print
> backtrace from __alloc_pages_slowpath() when ALLOC_NO_WATERMARKS is used?

Wouldn't this create too much output for slow serial console?
Or is this case supposed to be triggered rarely?

This crash testing is pretty painful but I can try it tomorrow
if there is no better idea.

Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
