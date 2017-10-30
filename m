Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 313FF6B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 02:18:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r18so12570646pgu.9
        for <linux-mm@kvack.org>; Sun, 29 Oct 2017 23:18:54 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m3si8884578plt.232.2017.10.29.23.18.51
        for <linux-mm@kvack.org>;
        Sun, 29 Oct 2017 23:18:52 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH] locking/lockdep: Revise Documentation/locking/crossrelease.txt
Date: Mon, 30 Oct 2017 15:18:44 +0900
Message-Id: <1509344324-22399-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

I'm afraid the revision is not perfect yet. Of course, the document can
have got much better english by others than me.

But,

I think I should enhance it as much as I can, before they can help it
starting with a better one.

In addition, I removed verboseness as much as possible.

----->8-----
