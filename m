Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A95AB6B008C
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 03:29:37 -0500 (EST)
Received: by pvh11 with SMTP id 11so2144937pvh.14
        for <linux-mm@kvack.org>; Wed, 10 Mar 2010 00:29:37 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 10 Mar 2010 16:29:37 +0800
Message-ID: <2375c9f91003100029q7d64bbf7xce15eee97f7e2190@mail.gmail.com>
Subject: 2.6.34-rc1: kernel BUG at mm/slab.c:2989!
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello, mm experts,

I triggered an mm bug today, the full backtrace is here:

http://pastebin.ca/1831436

I am using yesterday's Linus tree.

It's not easy to reproduce this, I got this very randomly.

Some related config's are:

CONFIG_SLAB=y
CONFIG_SLABINFO=y
# CONFIG_DEBUG_SLAB is not set

Please let me know if you need more info.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
