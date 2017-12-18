Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9F86B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 15:02:51 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n126so21940wma.7
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 12:02:51 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id a69si84601wme.11.2017.12.18.12.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 12:02:49 -0800 (PST)
Date: Mon, 18 Dec 2017 20:02:44 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v3] mm,vmscan: Make unregister_shrinker() no-op if
 register_shrinker() failed.
Message-ID: <20171218200244.GO21978@ZenIV.linux.org.uk>
References: <1513596701-4518-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513596701-4518-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Aliaksei Karaliou <akaraliou.dev@gmail.com>, Glauber Costa <glauber@scylladb.com>, syzbot <syzkaller@googlegroups.com>

On Mon, Dec 18, 2017 at 08:31:41PM +0900, Tetsuo Handa wrote:
> Syzbot caught an oops at unregister_shrinker() because combination of
> commit 1d3d4437eae1bb29 ("vmscan: per-node deferred work") and fault
> injection made register_shrinker() fail and the caller of
> register_shrinker() did not check for failure.

Applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
