Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95A936B0003
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 00:55:31 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e1so704298pfi.10
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 21:55:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b11-v6si1843542plm.241.2018.01.27.21.55.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Jan 2018 21:55:30 -0800 (PST)
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180124013651.GA1718@codemonkey.org.uk>
 <20180127222433.GA24097@codemonkey.org.uk>
 <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
 <d726458d-3d3b-5580-ddfc-2914cbf756ba@I-love.SAKURA.ne.jp>
 <7771dd55-2655-d3a9-80ee-24c9ada7dbbe@I-love.SAKURA.ne.jp>
Message-ID: <8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
Date: Sun, 28 Jan 2018 14:55:28 +0900
MIME-Version: 1.0
In-Reply-To: <7771dd55-2655-d3a9-80ee-24c9ada7dbbe@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Network Development <netdev@vger.kernel.org>

Dave, would you try below patch?
