Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBCD82F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 13:10:52 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id l127so185735656iof.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 10:10:52 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id w42si42208392ioi.91.2016.02.22.10.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 10:10:51 -0800 (PST)
Message-Id: <20160222181040.553533936@linux.com>
Date: Mon, 22 Feb 2016 12:10:40 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [patch 0/2] vmstat: Speedup and Cleanup
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hannes@cmpxchg.org, mgorman@suse.de

I have not been too satisfied with the recent code changes and in
particular not fond of the races and the performance regressions
I have seen. So this is an attempt to address those by making some
small code changes and by removing the cpu_stat_off cpumask which
was the reason for the races.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
