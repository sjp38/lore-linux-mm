Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFEAA6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 06:22:10 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j134so13514464oib.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 03:22:10 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20093.outbound.protection.outlook.com. [40.107.2.93])
        by mx.google.com with ESMTPS id i15si525524otd.79.2016.07.07.03.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 03:22:10 -0700 (PDT)
Subject: Re: [PATCH v5] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
References: <1466617421-58518-1-git-send-email-glider@google.com>
 <577AF45A.5080503@oracle.com>
 <CAG_fn=WWWbeGkcxCnn37OBNjJiwVp=BHUeVX6T_5XACQQdJT5g@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <577E2D8B.8060404@virtuozzo.com>
Date: Thu, 7 Jul 2016 13:23:07 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=WWWbeGkcxCnn37OBNjJiwVp=BHUeVX6T_5XACQQdJT5g@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 07/07/2016 01:01 PM, Alexander Potapenko wrote:
> Any idea which config option triggers this code path?
> I don't see it with my config, and the config from kbuild doesn't boot for me.
> (I'm trying to bisect the diff between them now)
> 

Boot with slub_debug=FPZU.

As I said before, check_pad_bytes() is broken. Sasha's problem very likely caused by it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
