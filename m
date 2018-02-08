Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id ABEE26B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 16:04:50 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id r84so4747485qki.19
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 13:04:50 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 12si832436qtn.63.2018.02.08.13.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 13:04:50 -0800 (PST)
Date: Thu, 08 Feb 2018 16:04:48 -0500 (EST)
Message-Id: <20180208.160448.186357541261251073.davem@redhat.com>
Subject: Re: [PATCH] net: Whitelist the skbuff_head_cache "cb" field
From: David Miller <davem@redhat.com>
In-Reply-To: <CAGXu5jJsmECUtyXBJb60o_Ve3PTUw8pkyaH2=SFHSxHy1vjsmA@mail.gmail.com>
References: <20180208014438.GA12186@beast>
	<20180208.151621.581060088482890871.davem@davemloft.net>
	<CAGXu5jJsmECUtyXBJb60o_Ve3PTUw8pkyaH2=SFHSxHy1vjsmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org
Cc: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, ebiggers3@gmail.com, james.morse@arm.com, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-mm@kvack.org

From: Kees Cook <keescook@chromium.org>
Date: Fri, 9 Feb 2018 08:01:12 +1100

> Cool, thanks. And just to be clear, if it's not already obvious, this
> patch needs kmem_cache_create_usercopy() which just landed in Linus's
> tree last week, in case you've not merged yet.

Understood, and 'net' has it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
