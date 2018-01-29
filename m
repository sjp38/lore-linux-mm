Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id D7AC96B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 16:31:07 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id v26so6871448uaj.19
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 13:31:07 -0800 (PST)
Received: from scorn.kernelslacker.org (scorn.kernelslacker.org. [2600:3c03::f03c:91ff:fe59:ec69])
        by mx.google.com with ESMTPS id 27si12896880qtr.83.2018.01.28.18.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Jan 2018 18:43:16 -0800 (PST)
Date: Sun, 28 Jan 2018 21:43:12 -0500
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
Message-ID: <20180129024312.GA29421@codemonkey.org.uk>
References: <20180124013651.GA1718@codemonkey.org.uk>
 <20180127222433.GA24097@codemonkey.org.uk>
 <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
 <d726458d-3d3b-5580-ddfc-2914cbf756ba@I-love.SAKURA.ne.jp>
 <7771dd55-2655-d3a9-80ee-24c9ada7dbbe@I-love.SAKURA.ne.jp>
 <8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Network Development <netdev@vger.kernel.org>

On Sun, Jan 28, 2018 at 02:55:28PM +0900, Tetsuo Handa wrote:
 > Dave, would you try below patch?
 > 
 > >From cae2cbf389ae3cdef1b492622722b4aeb07eb284 Mon Sep 17 00:00:00 2001
 > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
 > Date: Sun, 28 Jan 2018 14:17:14 +0900
 > Subject: [PATCH] lockdep: Fix fs_reclaim warning.


Seems to suppress the warning for me.

Tested-by: Dave Jones <davej@codemonkey.org.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
