Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0D98E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:41:43 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so205124edc.9
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:41:43 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v11si8467164edj.211.2019.01.07.03.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 03:41:42 -0800 (PST)
Date: Mon, 7 Jan 2019 12:41:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
Message-ID: <20190107114139.GF31793@dhcp22.suse.cz>
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun 06-01-19 15:02:24, Tetsuo Handa wrote:
> Michal and Johannes, can we please stop this stupid behavior now?

I have proposed a patch with a much more limited scope which is still
waiting for feedback. I haven't heard it wouldn't be working so far.
-- 
Michal Hocko
SUSE Labs
