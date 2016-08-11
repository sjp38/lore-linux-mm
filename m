Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 434AD6B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:31:49 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q62so14848626oih.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:31:49 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0096.outbound.protection.outlook.com. [104.47.2.96])
        by mx.google.com with ESMTPS id p45si2044128otd.217.2016.08.11.08.31.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 08:31:47 -0700 (PDT)
Subject: Re: [PATCH] kasan: remove the unnecessary WARN_ONCE from quarantine.c
References: <1470929182-101413-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <28ad8d12-f987-5538-2323-49aca7a11ce1@virtuozzo.com>
Date: Thu, 11 Aug 2016 18:32:58 +0300
MIME-Version: 1.0
In-Reply-To: <1470929182-101413-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, dvyukov@google.com, kcc@google.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 08/11/2016 06:26 PM, Alexander Potapenko wrote:
> It's quite unlikely that the user will so little memory that the
> per-CPU quarantines won't fit into the given fraction of the available
> memory. Even in that case he won't be able to do anything with the
> information given in the warning.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
