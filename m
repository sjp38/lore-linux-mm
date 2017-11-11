Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC922802B4
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 08:26:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 190so7091511pgh.16
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 05:26:37 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v81si11663945pfk.236.2017.11.11.05.26.34
        for <linux-mm@kvack.org>;
        Sat, 11 Nov 2017 05:26:36 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 0/5] Revise crossrelease.txt
Date: Sat, 11 Nov 2017 22:26:27 +0900
Message-Id: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

In this version, I've split a big one into small 5 patches so you can
review them more easily. But, choose between a big one and small 5
patches when you take it, as you prefer.

I will add a big one merging all of these.

---

Changes from v2
- Split a big patch into small 5 patches.
- Apply what Ingo pointed out.
- Leave original contents unchanged as much as possible.

Changes from v1
- Run several tools checking english spell and grammar over the text.
- Simplify the document more.

Byungchul Park (5):
  locking/Documentation: Remove meaningless examples and a note
  locking/Documentation: Fix typos and clear grammar errors
  locking/Documentation: Fix weird expressions.
  locking/Documentation: Add an example to help crossrelease.txt more
    readable
  locking/Documentation: Align crossrelease.txt with the width

 Documentation/locking/crossrelease.txt | 329 ++++++++++++++++-----------------
 1 file changed, 155 insertions(+), 174 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
