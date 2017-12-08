Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1226F6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 23:40:36 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k104so5271711wrc.19
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 20:40:36 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d8sor3475152wrb.48.2017.12.07.20.40.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 20:40:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJuCfpHV=O4Kq4jppeMu7A==N37VhmXvHYRYvERmxQVeEZ=jUQ@mail.gmail.com>
References: <20171206192026.25133-1-surenb@google.com> <20171207083436.GC20234@dhcp22.suse.cz>
 <CAJuCfpHV=O4Kq4jppeMu7A==N37VhmXvHYRYvERmxQVeEZ=jUQ@mail.gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 7 Dec 2017 20:40:33 -0800
Message-ID: <CAJuCfpE+iM0r3E-eeBGDDo5k=i8qar+im+STfsMG75fc+Vpm6w@mail.gmail.com>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

> According to my traces this 43ms could drop to the average of 11ms and
> worst case 25ms if throttle_direct_reclaim would return true when
> fatal signal is pending but I would like to hear your opinion about
> throttle_direct_reclaim logic.

Digging some more into this I realize my last statement might be
incorrect. Throttling in this situation might not help with the signal
handling delay because of the logic in __alloc_pages_slowpath. I'll
have to experiment with this first, please disregard that last
statement for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
