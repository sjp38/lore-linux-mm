Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 130826B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 07:43:15 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id 2so9987335igy.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 04:43:15 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0142.outbound.protection.outlook.com. [157.55.234.142])
        by mx.google.com with ESMTPS id a20si443508ote.229.2016.06.08.04.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Jun 2016 04:43:14 -0700 (PDT)
Subject: Re: [PATCHv9 2/2] selftest/x86: add mremap vdso test
References: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
 <1463487232-4377-3-git-send-email-dsafonov@virtuozzo.com>
 <20160520064820.GB29418@gmail.com>
 <CALCETrWznziSzwu3gG6bcFAxPvboTF519iTS6F8+WVW0B4i4UQ@mail.gmail.com>
 <20160521202752.GA31710@gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <5f3100e6-84f8-e565-1d89-2ee2eafa1148@virtuozzo.com>
Date: Wed, 8 Jun 2016 14:41:53 +0300
MIME-Version: 1.0
In-Reply-To: <20160521202752.GA31710@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

On 05/21/2016 11:27 PM, Ingo Molnar wrote:
> Will look at applying this after the merge window.

Ping?

Thanks,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
