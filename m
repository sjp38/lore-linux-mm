Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6070B6B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 12:45:22 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id b10so1211769eae.27
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 09:45:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z8si5856071eee.125.2014.03.05.09.45.19
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 09:45:20 -0800 (PST)
Date: Wed, 5 Mar 2014 12:45:03 -0500
From: Dave Jones <davej@redhat.com>
Subject: bad rss-counter message in 3.14rc5
Message-ID: <20140305174503.GA16335@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

I just saw this on my box that's been running trinity..

[48825.517189] BUG: Bad rss-counter state mm:ffff880177921d40 idx:0 val:1 (Not tainted)

There's nothing else, no trace, nothing.  Any ideas where to begin with this?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
