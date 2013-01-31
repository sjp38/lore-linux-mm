Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 9FFD76B000D
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 14:08:26 -0500 (EST)
Received: by mail-qe0-f41.google.com with SMTP id 7so1461493qeb.28
        for <linux-mm@kvack.org>; Thu, 31 Jan 2013 11:08:25 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
Date: Thu, 31 Jan 2013 20:08:24 +0100
Message-ID: <CA+icZUViijkp+SeSSF-DbWMin6C3Q-P=Fyz6aAvDaPfQOmPvFw@mail.gmail.com>
Subject: Re: next-20130128 lockdep whinge in sys_swapon()
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-next <linux-next@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Shaohua Li <shli@kernel.org>, linux-mm <linux-mm@kvack.org>

Original posting [1].

In this area I remember a patch [2] from Hugh.
Can you try that and report?

- Sedat -

[1] http://marc.info/?l=linux-kernel&m=135965796810525&w=2
[2] http://www.gossamer-threads.com/lists/linux/kernel/1668102

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
