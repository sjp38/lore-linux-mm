Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7BEC6B02A1
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 11:53:38 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b132so9196249iti.5
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:53:38 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20112.outbound.protection.outlook.com. [40.107.2.112])
        by mx.google.com with ESMTPS id 139si2554228itv.64.2016.11.15.08.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 08:53:38 -0800 (PST)
Subject: Re: [PATCH] kasan: update kasan_global for gcc 7
References: <1479219743-28682-1-git-send-email-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a5e7101f-5af7-0cac-3fa7-7ee1bea2207b@virtuozzo.com>
Date: Tue, 15 Nov 2016 19:53:56 +0300
MIME-Version: 1.0
In-Reply-To: <1479219743-28682-1-git-send-email-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, glider@google.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 11/15/2016 05:22 PM, Dmitry Vyukov wrote:
> kasan_global struct is part of compiler/runtime ABI.
> gcc revision 241983 has added a new field to kasan_global struct.
> Update kernel definition of kasan_global struct to include
> the new field.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: aryabinin@virtuozzo.com
> Cc: glider@google.com
> Cc: akpm@linux-foundation.org
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
