Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85E246B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 11:33:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h18so585339pfi.2
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 08:33:31 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0132.outbound.protection.outlook.com. [104.47.0.132])
        by mx.google.com with ESMTPS id s62si330063pfe.119.2017.12.05.08.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 08:33:30 -0800 (PST)
Subject: Re: [PATCH v4 4/5] kasan: Add tests for alloca poisoning
References: <20171204191735.132544-1-paullawrence@google.com>
 <20171204191735.132544-5-paullawrence@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f0ae37b7-1560-f079-6c93-089c9e7b5a31@virtuozzo.com>
Date: Tue, 5 Dec 2017 19:36:58 +0300
MIME-Version: 1.0
In-Reply-To: <20171204191735.132544-5-paullawrence@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>



On 12/04/2017 10:17 PM, Paul Lawrence wrote:
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
> ---
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
