Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC12E6B0272
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:52:18 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so13567884pff.0
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:52:18 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0118.outbound.protection.outlook.com. [104.47.2.118])
        by mx.google.com with ESMTPS id d62si9672058pga.87.2017.12.04.08.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:52:17 -0800 (PST)
Subject: Re: [PATCH v3 3/5] kasan: support alloca() poisoning
References: <20171201213643.2506-1-paullawrence@google.com>
 <20171201213643.2506-4-paullawrence@google.com>
 <20171204164240.GA24425@infradead.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <fb09a40f-1fae-ce4c-9d7c-a13c284b19e9@virtuozzo.com>
Date: Mon, 4 Dec 2017 19:55:37 +0300
MIME-Version: 1.0
In-Reply-To: <20171204164240.GA24425@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Paul Lawrence <paullawrence@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>



On 12/04/2017 07:42 PM, Christoph Hellwig wrote:
> I don't think we are using alloca in kernel mode code, and we shouldn't.
> What do I miss?  Is this hidden support for on-stack VLAs?  I thought
> we'd get rid of them as well.
> 

Yes, this is for on-stack VLA. Last time I checked, we still had a few.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
