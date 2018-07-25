Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E128F6B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 20:24:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w1-v6so4014578ply.12
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 17:24:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d13-v6sor3538602pgt.331.2018.07.24.17.24.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 17:24:33 -0700 (PDT)
Date: Tue, 24 Jul 2018 17:24:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v4] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <f2e09fbf-700c-19d6-7dd8-42683507b5d1@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807241722580.49968@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com> <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com> <alpine.DEB.2.21.1807201314230.231119@chino.kir.corp.google.com> <ca34b123-5c81-569f-85ea-4851bc569962@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807201505550.38399@chino.kir.corp.google.com>
 <f8d24892-b05e-73a8-36d5-4fe278f84c44@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807241444370.206335@chino.kir.corp.google.com> <05dbc69a-1c26-adec-15c6-f7192f8d2ae0@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807241549420.215249@chino.kir.corp.google.com>
 <f2e09fbf-700c-19d6-7dd8-42683507b5d1@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Jul 2018, Tetsuo Handa wrote:

> > If exit_mmap() gets preempted indefinitely before it can free any memory, 
> > we are better off oom killing another process.  The purpose of the timeout 
> > is to give an oom victim an amount of time to free its memory and exit 
> > before selecting another victim.
> > 
> 
> There is no point with emitting the noise.
> 

If you're concerned about too many printk's to the kernel log, 
oom_reap_task_mm() could store whether MMF_UNSTABLE was set or not before 
attempting to reap and then only printk if this was the first oom reaping.

We lose the ability to determine if subsequent reaps freed additional 
memory, but I don't suppose that's too concerning.
