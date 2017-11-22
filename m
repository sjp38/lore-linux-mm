Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96D096B0261
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:01:30 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x66so14429059pfe.21
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:01:30 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10131.outbound.protection.outlook.com. [40.107.1.131])
        by mx.google.com with ESMTPS id 70si13580565ple.808.2017.11.22.04.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 04:01:29 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <da3f79bc-ef84-d516-b659-1f213d46a79f@virtuozzo.com>
Date: Wed, 22 Nov 2017 15:04:51 +0300
MIME-Version: 1.0
In-Reply-To: <20171120015000.GA13507@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Wengang Wang <wen.gang.wang@oracle.com>, Linux-MM <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>

On 11/20/2017 04:50 AM, Joonsoo Kim wrote:
> 
> The reason I didn't submit the vchecker to mainline is that I didn't find
> the case that this tool is useful in real life. Most of the system broken case
> can be debugged by other ways. Do you see the real case that this tool is
> helpful? If so, I think that vchecker is more appropriate to be upstreamed.
> Could you share your opinion?
> 

Isn't everything that vchecker can do and far beyond that can be done via systemtap
script using watchpoints?


> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
