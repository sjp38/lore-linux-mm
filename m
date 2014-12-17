Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5CABF6B006C
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 18:06:57 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id rd18so65532iec.15
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 15:06:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g30si3884049iod.35.2014.12.17.15.06.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Dec 2014 15:06:56 -0800 (PST)
Date: Wed, 17 Dec 2014 15:06:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mempool.c: Replace io_schedule_timeout with io_schedule
Message-Id: <20141217150654.e857603cebd4f97c794a2dff@linux-foundation.org>
In-Reply-To: <1418560486-21685-1-git-send-email-nefelim4ag@gmail.com>
References: <1418560486-21685-1-git-send-email-nefelim4ag@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org

On Sun, 14 Dec 2014 15:34:46 +0300 Timofey Titovets <nefelim4ag@gmail.com> wrote:

> io_schedule_timeout(5*HZ);
> Introduced for avoidance dm bug:
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2006-08/msg04869.html
> According to description must be replaced with io_schedule()
> 
> I replace it and recompile kernel, tested it by following script:

How do we know DM doesn't still depend on the io_schedule_timeout()?

It would require input from the DM developers and quite a lot of
stress-testing of many kernel subsystems before we could make this
change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
