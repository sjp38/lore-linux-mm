Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 834A96B0299
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 13:42:51 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q13so1800505pgt.17
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 10:42:51 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id n24si142522pfa.269.2018.02.06.10.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 10:42:50 -0800 (PST)
Date: Tue, 06 Feb 2018 13:42:45 -0500 (EST)
Message-Id: <20180206.134245.680837561909396767.davem@davemloft.net>
Subject: Re: [PATCH v2] socket: Provide put_cmsg_whitelist() for constant
 size copies
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAGXu5j+JnJKQocO4LxshbPZ0HPO+sQ71D+iCtCJN1YJzKn2G0g@mail.gmail.com>
References: <CAGXu5j+VnhgXFajjxR7HJkN=Z6r3Kfw-+Gg2x37AacOD6C+Wdg@mail.gmail.com>
	<20180206.111949.1986970583522698316.davem@davemloft.net>
	<CAGXu5j+JnJKQocO4LxshbPZ0HPO+sQ71D+iCtCJN1YJzKn2G0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org
Cc: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, ebiggers3@gmail.com, james.morse@arm.com, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-mm@kvack.org, mingo@kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 7 Feb 2018 05:36:02 +1100

> Making put_cmsg() inline would help quite a bit with tracking the
> builtin_const-ness, and that could speed things up a little bit too.
> Would you be opposed to inlining?

Nope.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
