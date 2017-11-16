Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 676B76B0033
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:24:27 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id e19so814851qte.15
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 14:24:27 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id v23si2079244qta.244.2017.11.16.14.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 Nov 2017 14:24:23 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 2a2e7eb1
	for <linux-mm@kvack.org>;
	Thu, 16 Nov 2017 22:19:58 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id f2e90f8c (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Thu, 16 Nov 2017 22:19:57 +0000 (UTC)
Received: by mail-ot0-f182.google.com with SMTP id d27so489040ote.11
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 14:24:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170823211408.31198-1-ebiggers3@gmail.com>
References: <20170823211408.31198-1-ebiggers3@gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 16 Nov 2017 23:24:21 +0100
Message-ID: <CAHmME9rBoJBQi8QRpAK-Vzc1hWnN_UasjUfaxtrioJy1mLxGKw@mail.gmail.com>
Subject: Re: [PATCH] fork: fix incorrect fput of ->exe_file causing use-after-free
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Eric Biggers <ebiggers@google.com>

Hey Eric,

This is a pretty late response to the thread, but in case you're
curious, since Ubuntu forgot to backport this (I already emailed them
about it), I actually experienced a set of boxes that hit this bug in
the wild and were crashing every 2 weeks or so, when under highload.
It's pretty amazing that syzkaller unearthed this, resulting in a nice
test case, making it possible to debug and fix the error. Otherwise
it'd be a real heisenbug.

So, thanks.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
