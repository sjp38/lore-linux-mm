Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1A16B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 06:07:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 81so40729748pgh.3
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:07:42 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0113.outbound.protection.outlook.com. [104.47.0.113])
        by mx.google.com with ESMTPS id c9si1708266pge.334.2017.03.30.03.07.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 03:07:41 -0700 (PDT)
Subject: Re: [PATCH v3] mm: Allow calling vfree() from non-schedulable
 context.
References: <1490784712-4991-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170330082001.GB11344@lst.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <58c68d9c-ee81-82e0-3a2d-df7dd8f39dcd@virtuozzo.com>
Date: Thu, 30 Mar 2017 13:09:00 +0300
MIME-Version: 1.0
In-Reply-To: <20170330082001.GB11344@lst.de>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Chris Wilson <chris@chris-wilson.co.uk>, Ingo Molnar <mingo@elte.hu>, Jisheng Zhang <jszhang@marvell.com>, Joel Fernandes <joelaf@google.com>, John Dias <joaodias@google.com>, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On 03/30/2017 11:20 AM, Christoph Hellwig wrote:
> Maybe the right fix is to drop any support for non-user context in
> vfree and call vfree_deferred explicitly?
> 

Sounds like a lot of work. Also we could easily miss some calls.
And I don't see the point of it, it's just easier and safer to make vfree()
atomic-safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
