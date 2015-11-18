Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3E10E82F6C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:48:33 -0500 (EST)
Received: by wmec201 with SMTP id c201so285206425wme.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:48:32 -0800 (PST)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id kt2si4773110wjb.176.2015.11.18.07.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 07:48:32 -0800 (PST)
Subject: Re: [PATCH v7 0/4] KASAN for arm64
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com> <5649F783.40109@gmail.com>
 <20151116165100.GE6556@e104818-lin.cambridge.arm.com>
 <564C8C47.1080904@gmail.com>
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Message-ID: <564C9DCC.50205@arm.com>
Date: Wed, 18 Nov 2015 15:48:28 +0000
MIME-Version: 1.0
In-Reply-To: <564C8C47.1080904@gmail.com>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, linux-arm-kernel@lists.infradead.org

On 18/11/15 14:33, Andrey Ryabinin wrote:

> Is there any way to run 16K pages on emulated environment?
> I've tried:
>   - ARM V8 Foundation Platformr0p0 (platform build 9.4.59)

Have you tried with the following option ?

-C cluster<N>.has_16k_granule=3D1

Thanks
Suzuki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
