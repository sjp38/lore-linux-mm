Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE4D96B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 13:40:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b9so49291679qtg.4
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 10:40:21 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id y88si12523727qtd.8.2017.04.03.10.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 10:40:20 -0700 (PDT)
Received: by mail-qk0-x233.google.com with SMTP id p22so120958377qka.3
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 10:40:20 -0700 (PDT)
MIME-Version: 1.0
From: Raymond Jennings <shentino@gmail.com>
Date: Mon, 3 Apr 2017 10:39:39 -0700
Message-ID: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
Subject: Heavy I/O causing slow interactivity
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

I'm running gentoo and it's emerging llvm.  This I/O heavy process is
causing slowdowns when I attempt interactive stuff, including watching
a youtube video and accessing a chatroom.

Similar latency is induced during a heavy database application.

As an end user is there anything I can do to better support
interactive performance?

And as a potential kernel developer, is there anything I could tweak
in the kernel source to mitigate this behavior?

I've tried SCHED_IDLE and idle class with ionice, both to no avail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
