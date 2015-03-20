Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0696B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:42:51 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so118168546pac.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:42:51 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id oz10si11299125pdb.15.2015.03.20.12.42.49
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 12:42:50 -0700 (PDT)
Date: Fri, 20 Mar 2015 15:42:47 -0400 (EDT)
Message-Id: <20150320.154247.1709779134937698942.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
References: <CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>
	<550C5078.8040402@oracle.com>
	<CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: david.ahern@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 20 Mar 2015 09:58:25 -0700

> 128 cpu's is still "unusual"

As unusual as the system I do all of my kernel builds on :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
