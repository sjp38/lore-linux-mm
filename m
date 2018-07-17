Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 893246B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 00:22:45 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m2-v6so26020848plt.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 21:22:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k6-v6sor1408051pls.23.2018.07.16.21.22.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 21:22:44 -0700 (PDT)
Date: Mon, 16 Jul 2018 21:22:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, oom: remove oom_lock from exit_mmap
In-Reply-To: <44d26c25-6e09-49de-5e90-3c16115eb337@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807162121040.157949@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com> <20180713142612.GD19960@dhcp22.suse.cz> <44d26c25-6e09-49de-5e90-3c16115eb337@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 14 Jul 2018, Tetsuo Handa wrote:

> David is making changes using timeout based back off (in linux-next.git)
> which is inappropriately trying to use MMF_UNSTABLE for two purposes.
> 

If you believe there is a problem with the use of MMF_UNSTABLE as it sits 
in -mm, please follow up directly in the thread that proposed the patch.  
I have seen two replies to that thread from you: one that incorporates it 
into your work, and one that links to a verison of my patch in your 
patchset.  I haven't seen a concern raised about the use of MMF_UNSTABLE, 
but perhaps it's somewhere in the 10,000 other emails about the oom 
killer.
