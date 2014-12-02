Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 77BD16B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 23:19:12 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so12288014pdj.7
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 20:19:12 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id sf2si31759913pbb.99.2014.12.01.20.19.10
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 20:19:11 -0800 (PST)
Date: Tue, 2 Dec 2014 13:22:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] Fix memory ordering bug in mm/vmalloc.c.
Message-ID: <20141202042214.GA6268@js1304-P5Q-DELUXE>
References: <1417421486-13976-1-git-send-email-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417421486-13976-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: akpm@linux-foundation.org, edumazet@google.com, linux-mm@kvack.org

On Mon, Dec 01, 2014 at 11:11:26AM +0300, Dmitry Vyukov wrote:
> Read memory barriers must follow the read operations.

Hello, Dmitry.

You are right.
Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
