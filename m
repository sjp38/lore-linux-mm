Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3C818E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 20:23:37 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id n22so7643321otq.8
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 17:23:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i20si5789157oto.71.2019.01.20.17.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 17:23:36 -0800 (PST)
Message-Id: <201901210123.x0L1NLFJ043029@www262.sakura.ne.jp>
Subject: Re: [PATCH] mm, oom: remove 'prefer children over parent' heuristic
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Mon, 21 Jan 2019 10:23:21 +0900
References: <20190120215059.183552-1-shakeelb@google.com>
In-Reply-To: <20190120215059.183552-1-shakeelb@google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Shakeel Butt wrote:
> +	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> +		message, task_pid_nr(p), p->comm, oc->chosen_points);

This patch is to make "or sacrifice child" false. And, the process reported
by this line will become always same with the process reported by

	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));

. Then, better to merge these pr_err() lines?
