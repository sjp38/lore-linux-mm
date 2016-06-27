Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A33B6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 08:15:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so70814888wme.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 05:15:28 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id 16si26059413wjh.52.2016.06.27.05.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 05:15:27 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id v199so97662940wmv.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 05:15:27 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] TIF_MEMDIE usage fixlet
Date: Mon, 27 Jun 2016 14:15:17 +0200
Message-Id: <1467029719-17602-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Miao Xie <miaox@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

Hi,
while I was looking to move TIF_MEMDIE out of the thread info for other purpose
I have noticed these two usages which are not correct. I do not think any of them
warrant a stable backport because it is highly unlikely they would ever hit but
it is better to have them fixed.

I would route them via Andrew unless anybody has anything against.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
