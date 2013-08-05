Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 571206B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:04:26 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id xn12so6106920obc.6
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 11:04:25 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 5 Aug 2013 11:04:25 -0700
Message-ID: <CAA25o9RO5+gYCTQuouNsJ5COTWdA+wbPUH--B-STSmySjTxBAQ@mail.gmail.com>
Subject: swap behavior during fast allocation
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Greetings MM experts,

we (Chrome OS) are experiencing episodes of extremely sluggish
interactive response, i.e. tens of seconds delay between an action
(such as typing something) and the corresponding screen update during
times of very fast allocation, while using zram.

We can reproduce this by running a few processes that mmap large
chunks of memory, then randomly touch pages to fault them in.  We also
think this happens when a process writes a large amount of data using
buffered I/O, and the "Buffers" field in /proc/meminfo exceeds 1GB.
(This is something that can and should be corrected by using
unbuffered I/O instead, but it's a data point.)

We're wondering if this problem has been noticed before and what folks
do to ameliorate the situation.  Specifically, is there any way to
throttle the rate of allocation when the system is swapping?

Thanks!
Luigi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
