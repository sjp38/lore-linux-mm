Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 083AB6B0038
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 11:32:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d4so534565pgv.4
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 08:32:32 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0097.outbound.protection.outlook.com. [104.47.0.97])
        by mx.google.com with ESMTPS id m1si289162plb.521.2017.12.05.08.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 08:32:23 -0800 (PST)
Subject: Re: [PATCH v4 1/5] kasan: add compiler support for clang
References: <20171204191735.132544-1-paullawrence@google.com>
 <20171204191735.132544-2-paullawrence@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5e96ec6f-214a-b623-eb1e-c50d91ba4819@virtuozzo.com>
Date: Tue, 5 Dec 2017 19:35:51 +0300
MIME-Version: 1.0
In-Reply-To: <20171204191735.132544-2-paullawrence@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>



On 12/04/2017 10:17 PM, Paul Lawrence wrote:
> For now we can hard-code ASAN ABI level 5, since historical clang builds
> can't build the kernel anyway.  We also need to emulate gcc's
> __SANITIZE_ADDRESS__ flag, or memset() calls won't be instrumented.
> 
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
