Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id E45476B0037
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 05:02:41 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so8375041pbb.0
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 02:02:41 -0700 (PDT)
Received: by mail-la0-f53.google.com with SMTP id el20so6696300lab.12
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 02:02:38 -0700 (PDT)
Message-Id: <20131008090019.527108154@gmail.com>
Date: Tue, 08 Oct 2013 13:00:19 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [patch 0/3] Soft dirty tracking fixes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi! Here is a couple of fixes for soft dirty pages tracking.
While first two patches are adressing issues, the last one
is rather a cleanup which I've been asked to implement long
ago, but I'm not sure if anyone picked it up.

Please take a look, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
