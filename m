Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DAE46B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 12:08:38 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n69so384525318ion.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 09:08:38 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30122.outbound.protection.outlook.com. [40.107.3.122])
        by mx.google.com with ESMTPS id i22si1802655otc.179.2016.08.02.09.08.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 09:08:37 -0700 (PDT)
Subject: Re: [PATCH v2] kasan: avoid overflowing quarantine size on low memory
 systems
References: <1470133620-28683-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57A0C5C8.4030304@virtuozzo.com>
Date: Tue, 2 Aug 2016 19:09:44 +0300
MIME-Version: 1.0
In-Reply-To: <1470133620-28683-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, dvyukov@google.com, kcc@google.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/02/2016 01:27 PM, Alexander Potapenko wrote:
> If the total amount of memory assigned to quarantine is less than the
> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
> may overflow. Instead, set it to zero.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Fixes: 55834c59098d ("mm: kasan: initial memory quarantine
> implementation")
> Signed-off-by: Alexander Potapenko <glider@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
