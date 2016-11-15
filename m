Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1DA36B029E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 11:51:27 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id l8so8856589iti.6
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:51:27 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30127.outbound.protection.outlook.com. [40.107.3.127])
        by mx.google.com with ESMTPS id y16si16280286ioi.173.2016.11.15.08.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 08:51:26 -0800 (PST)
Subject: Re: [PATCH] kasan: support use-after-scope detection
References: <1479226045-145148-1-git-send-email-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <8a07a127-7b51-6301-5ac9-394651dc4f95@virtuozzo.com>
Date: Tue, 15 Nov 2016 19:51:43 +0300
MIME-Version: 1.0
In-Reply-To: <1479226045-145148-1-git-send-email-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, glider@google.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 11/15/2016 07:07 PM, Dmitry Vyukov wrote:
> Gcc revision 241896 implements use-after-scope detection.
> Will be available in gcc 7. Support it in KASAN.
> 
> Gcc emits 2 new callbacks to poison/unpoison large stack
> objects when they go in/out of scope.
> Implement the callbacks and add a test.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: aryabinin@virtuozzo.com
> Cc: glider@google.com
> Cc: akpm@linux-foundation.org
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> 
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
