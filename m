Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 062EF8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 18:35:41 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id p21so3189206iog.0
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:35:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m189si687613ita.78.2019.01.23.15.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 15:35:39 -0800 (PST)
Message-Id: <201901232335.x0NNZRWw042364@www262.sakura.ne.jp>
Subject: Re: [PATCH v3 1/2] mm, oom: fix use-after-free in
 =?ISO-2022-JP?B?b29tX2tpbGxfcHJvY2Vzcw==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 24 Jan 2019 08:35:27 +0900
References: <20190123225747.8715120856@mail.kernel.org> <CALvZod5h7fSoZTA+3bDTn93JuFgY=SUGEq=gpDYE8rdSfuNcPQ@mail.gmail.com>
In-Reply-To: <CALvZod5h7fSoZTA+3bDTn93JuFgY=SUGEq=gpDYE8rdSfuNcPQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Sasha Levin <sashal@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, stable@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

Shakeel Butt wrote:
> > How should we proceed with this patch?
> >
> 
> We do want to backport this patch to stable kernels. However shouldn't
> we wait for this patch to be applied to Linus's tree first.
> 

But since Andrew Morton seems to be offline since Jan 11, we don't know
when this patch will arrive at Linus's tree.
