Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 230606B007E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 13:31:41 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id n186so144978216wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 10:31:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bu3si5377226wjc.184.2016.03.08.10.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 10:31:39 -0800 (PST)
Date: Tue, 8 Mar 2016 13:30:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm,oom: Reduce needless dereference.
Message-ID: <20160308183032.GA9571@cmpxchg.org>
References: <1457434951-12691-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457434951-12691-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Tue, Mar 08, 2016 at 08:02:31PM +0900, Tetsuo Handa wrote:
> Since we assigned mm = victim->mm before pr_err(),
> we don't need to dereference victim->mm again at pr_err().
> This saves a few instructions.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Yes. Once we introduce a local variable for something, we should use
it consistently to refer to that thing. Anything else is confusing.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
