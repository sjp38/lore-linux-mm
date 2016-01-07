Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id CFEE26B0005
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 03:14:06 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id b14so110375100wmb.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 00:14:06 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id o10si165174145wjo.103.2016.01.07.00.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 00:14:05 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id u188so88081979wmu.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 00:14:05 -0800 (PST)
Date: Thu, 7 Jan 2016 09:14:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] oom reaper: handle anonymous mlocked pages
Message-ID: <20160107081402.GA27868@dhcp22.suse.cz>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
 <1452094975-551-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452094975-551-3-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 06-01-16 16:42:55, Michal Hocko wrote:
> Anonymous mappings
> are not visible by any other process so doing a munlock before unmap
> is safe to do from the semantic point of view.

I was too conservative here. I have completely forgoten about the lazy
mlock handling during try_to_unmap which would keep the page mlocked if
there is an mlocked vma mapping that page. So we can safely do what I
was proposing originally. I hope I am not missing anything now. Here is
the replacement patch
---
