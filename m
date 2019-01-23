Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D52E48E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 18:14:36 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id d72so2065932ywe.9
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:14:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x137sor2711312ywg.141.2019.01.23.15.14.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 15:14:35 -0800 (PST)
MIME-Version: 1.0
References: <20190121215850.221745-1-shakeelb@google.com> <20190123225747.8715120856@mail.kernel.org>
In-Reply-To: <20190123225747.8715120856@mail.kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 23 Jan 2019 15:14:24 -0800
Message-ID: <CALvZod5h7fSoZTA+3bDTn93JuFgY=SUGEq=gpDYE8rdSfuNcPQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm, oom: fix use-after-free in oom_kill_process
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, stable@kernel.org, stable@vger.kernel.org

On Wed, Jan 23, 2019 at 2:57 PM Sasha Levin <sashal@kernel.org> wrote:
>
> Hi,
>
> [This is an automated email]
>
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: 6b0c81b3be11 mm, oom: reduce dependency on tasklist_lock.
>
> The bot has tested the following trees: v4.20.3, v4.19.16, v4.14.94, v4.9.151, v4.4.171, v3.18.132.
>
> v4.20.3: Build OK!
> v4.19.16: Build OK!
> v4.14.94: Failed to apply! Possible dependencies:
>     5989ad7b5ede ("mm, oom: refactor oom_kill_process()")
>

Very easy to resolve the conflict. Please let me know if you want me
to send a version for 4.14-stable kernel.

> v4.9.151: Build OK!
> v4.4.171: Build OK!
> v3.18.132: Build OK!
>
>
> How should we proceed with this patch?
>

We do want to backport this patch to stable kernels. However shouldn't
we wait for this patch to be applied to Linus's tree first.

Shakeel
