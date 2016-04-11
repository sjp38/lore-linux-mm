Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DEBA96B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:40:39 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id v188so91803029wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:40:39 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id n2si29431921wja.109.2016.04.11.08.40.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 08:40:38 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id y144so22097547wmd.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:40:38 -0700 (PDT)
Date: Mon, 11 Apr 2016 17:40:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
Message-ID: <20160411154036.GN23157@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-10-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459855533-4600-10-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
Vlastimil has pointed out[1] that using compaction_withdrawn() for THP
allocations has some non-trivial consequences. While I still think that
the check is OK it is true we shouldn't sneak in a potential behavior
change into something that basically provides an API. So can you fold
the following partial revert into the original patch please?

[1] http://lkml.kernel.org/r/570BB719.2030007@suse.cz

---
