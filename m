Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3818E8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:19:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so7515273edi.0
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 01:19:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5-v6si1743091ejp.46.2019.01.21.01.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 01:19:29 -0800 (PST)
Date: Mon, 21 Jan 2019 10:19:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
Message-ID: <20190121091927.GK4087@dhcp22.suse.cz>
References: <20190119005022.61321-1-shakeelb@google.com>
 <20190119070934.GD4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190119070934.GD4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 19-01-19 08:09:34, Michal Hocko wrote:
[...]
> Fixes: 5e9d834a0e0c ("oom: sacrifice child with highest badness score for parent")

So I've double checked and I was wrong blaming this commit. Back then it
was tasklist_lock to protect us from releasing the task. It's been only
since 6b0c81b3be11 ("mm, oom: reduce dependency on tasklist_lock") that
we rely on the reference counting and unless I am missing something this
is also the commit which has introduced this bug.

> Cc: stable

-- 
Michal Hocko
SUSE Labs
