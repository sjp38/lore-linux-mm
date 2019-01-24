Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAE78E0047
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 03:13:10 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so3429981pgq.9
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 00:13:10 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m32si4853762pld.86.2019.01.24.00.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 00:13:09 -0800 (PST)
Date: Thu, 24 Jan 2019 09:13:06 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 1/2] mm, oom: fix use-after-free in oom_kill_process
Message-ID: <20190124081306.GA1344@kroah.com>
References: <20190123225747.8715120856@mail.kernel.org>
 <CALvZod5h7fSoZTA+3bDTn93JuFgY=SUGEq=gpDYE8rdSfuNcPQ@mail.gmail.com>
 <201901232335.x0NNZRWw042364@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201901232335.x0NNZRWw042364@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, Sasha Levin <sashal@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, stable@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jan 24, 2019 at 08:35:27AM +0900, Tetsuo Handa wrote:
> Shakeel Butt wrote:
> > > How should we proceed with this patch?
> > >
> > 
> > We do want to backport this patch to stable kernels. However shouldn't
> > we wait for this patch to be applied to Linus's tree first.

Yes we will.

> But since Andrew Morton seems to be offline since Jan 11, we don't know
> when this patch will arrive at Linus's tree.

That's fine, we can wait :)

greg k-h
