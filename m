Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 238E56B0006
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 23:10:36 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t19-v6so2267686plo.9
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 20:10:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a11-v6si2434941pfo.68.2018.07.03.20.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 20:10:34 -0700 (PDT)
Message-Id: <201807040226.w642Qk6k001082@www262.sakura.ne.jp>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional processes
From: penguin-kernel@i-love.sakura.ne.jp
MIME-Version: 1.0
Date: Wed, 04 Jul 2018 11:26:46 +0900
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <alpine.DEB.2.21.1807031841220.110853@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1807031841220.110853@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David Rientjes wrote:
> Ping?
> 
> This can be something that can easily be removed if it becomes obsoleted 
> because the oom reaper is always able to free memory to the extent of 
> exit_mmap().  I argue that it cannot, because it cannot do free_pgtables() 
> for large amounts of virtual memory, but am fine to be proved wrong.

This is "[PATCH 3/8] mm,oom: Fix unnecessary killing of additional processes." in my series.

> 
> In the meantime, however, this patch should introduce no significant 
> change in functionality and the only interface it is added is in debugfs 
> and can easily be removed if it is obsoleted.
> 
> The work to make the oom reaper more effective or realible can still 
> continue with this patch.
> 
