Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 836EC6B0032
	for <linux-mm@kvack.org>; Mon,  4 May 2015 15:01:05 -0400 (EDT)
Received: by wgin8 with SMTP id n8so159695258wgi.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 12:01:05 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id bb1si24042005wjb.154.2015.05.04.12.01.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 12:01:04 -0700 (PDT)
Received: by wgen6 with SMTP id n6so159954763wge.3
        for <linux-mm@kvack.org>; Mon, 04 May 2015 12:01:03 -0700 (PDT)
Date: Mon, 4 May 2015 21:01:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
Message-ID: <20150504190101.GC3626@dhcp22.suse.cz>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
 <20150504180210.GA2772@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150504180210.GA2772@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 04-05-15 14:02:10, Johannes Weiner wrote:
> Hi Andrew,
> 
> since patches 8 and 9 are still controversial, would you mind picking
> up just 1-7 for now?  They're cleaunps nice to have on their own.

Completely agreed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
