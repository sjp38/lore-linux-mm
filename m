Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2286B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 09:07:20 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l6so64003250wml.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 06:07:20 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id u72si2905160wmd.93.2016.04.08.06.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 06:07:19 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n3so4251517wmn.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 06:07:18 -0700 (PDT)
Date: Fri, 8 Apr 2016 15:07:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks
 queued for oom_reaper
Message-ID: <20160408130716.GI29820@dhcp22.suse.cz>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
 <1459951996-12875-4-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459951996-12875-4-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Andrew, could you please fold this in?
---
