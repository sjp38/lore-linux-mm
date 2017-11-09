Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7B7C440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 02:20:49 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id p186so7999116ioe.9
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 23:20:49 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id i7si5534365pgd.378.2017.11.08.23.20.46
        for <linux-mm@kvack.org>;
        Wed, 08 Nov 2017 23:20:47 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2] locking/lockdep: Revise Documentation/locking/crossrelease.txt
Date: Thu,  9 Nov 2017 16:20:36 +0900
Message-Id: <1510212036-22008-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

Changes from v1
- Run several tools checking english spell and grammar over the text.
- Simplify the document more.

-----8<-----
