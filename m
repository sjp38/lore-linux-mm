Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BB9A6B0587
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 02:44:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h126so15196194wmf.10
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 23:44:59 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id d43si23290556wrd.85.2017.07.28.23.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 23:44:58 -0700 (PDT)
Message-ID: <1501310327.4777.41.camel@gmx.de>
Subject: Re: [PATCH 0/3] memdelay: memory health metric for systems and
 workloads
From: Mike Galbraith <efault@gmx.de>
Date: Sat, 29 Jul 2017 08:38:47 +0200
In-Reply-To: <1501296502.12260.19.camel@gmx.de>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
	 <1501296502.12260.19.camel@gmx.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, 2017-07-29 at 04:48 +0200, Mike Galbraith wrote:
> ttwu asm delta says "measure me".

q/d measurement with pipe-test

+cgroup_disable=memory
2.241926 usecs/loop -- avg 2.242376 891.9 KHz  1.000
+patchset
2.284428 usecs/loop -- avg 2.357621 848.3 KHz   .951

-cgroup_disable=memory
2.257433 usecs/loop -- avg 2.327356 859.3 KHz  1.000
+patchset
2.394804 usecs/loop -- avg 2.404556 831.8 KHz   .967

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
