Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 270998E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:57:49 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so2917180pfj.3
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:57:49 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x74si8303366pfe.23.2019.01.23.14.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:57:48 -0800 (PST)
Date: Wed, 23 Jan 2019 22:57:46 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH v3 1/2] mm, oom: fix use-after-free in oom_kill_process
In-Reply-To: <20190121215850.221745-1-shakeelb@google.com>
References: <20190121215850.221745-1-shakeelb@google.com>
Message-Id: <20190123225747.8715120856@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, stable@kernel.orglinux-mm@kvack.orglinux-kernel@vger.kernel.org, stable@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 6b0c81b3be11 mm, oom: reduce dependency on tasklist_lock.

The bot has tested the following trees: v4.20.3, v4.19.16, v4.14.94, v4.9.151, v4.4.171, v3.18.132.

v4.20.3: Build OK!
v4.19.16: Build OK!
v4.14.94: Failed to apply! Possible dependencies:
    5989ad7b5ede ("mm, oom: refactor oom_kill_process()")

v4.9.151: Build OK!
v4.4.171: Build OK!
v3.18.132: Build OK!


How should we proceed with this patch?

--
Thanks,
Sasha
