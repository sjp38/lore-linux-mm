Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 97C706B00AC
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 11:42:25 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id w10so8633247pde.27
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 08:42:25 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q1si2508679pdi.64.2014.09.11.08.42.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 08:42:24 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 0/2] Anonymous memory threshold notifications for memcg
Date: Thu, 11 Sep 2014 19:41:48 +0400
Message-ID: <cover.1410447097.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

Hi,

This series introduces anonymous memory threshold notifications for
memory cgroups. For rationale please see the comment to patch 2.

I'm sending it to attract attention to the following thread:

http://www.spinics.net/lists/linux-mm/msg78180.html

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
