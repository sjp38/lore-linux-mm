Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6845F6B0069
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 13:45:42 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id b202so195677591oii.3
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 10:45:42 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0062.outbound.protection.outlook.com. [104.47.37.62])
        by mx.google.com with ESMTPS id w66si21899819otb.267.2016.12.12.10.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 10:45:41 -0800 (PST)
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
References: <20161209230851.GB64048@google.com>
 <CALCETrWfa5VJQNu3XjeFhF0cDFWF+M-dPwsT_7dzO5YSxsneGg@mail.gmail.com>
From: Gary R Hook <ghook@amd.com>
Message-ID: <1747e6e9-35dc-48cc-7345-4f0412ba2521@amd.com>
Date: Mon, 12 Dec 2016 12:45:18 -0600
MIME-Version: 1.0
In-Reply-To: <CALCETrWfa5VJQNu3XjeFhF0cDFWF+M-dPwsT_7dzO5YSxsneGg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Eric Biggers <ebiggers3@gmail.com>
Cc: linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Herbert Xu <herbert@gondor.apana.org.au>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On 12/12/2016 12:34 PM, Andy Lutomirski wrote:

<...snip...>

>
> I have a patch to make these depend on !VMAP_STACK.
>
>>         drivers/crypto/ccp/ccp-crypto-aes-cmac.c:105,119,142
>>         drivers/crypto/ccp/ccp-crypto-sha.c:95,109,124
>>         drivers/crypto/ccp/ccp-crypto-aes-xts.c:162
>>         drivers/crypto/ccp/ccp-crypto-aes.c:94
>
> According to Herbert, these are fine.  I'm personally less convinced
> since I'm very confused as to what "async" means in the crypto code,
> but I'm going to leave these alone.

I went back through the code, and AFAICT every argument to sg_init_one() in
the above-cited files is a buffer that is part of the request context. Which
is allocated by the crypto framework, and therefore will never be on the 
stack.
Right?

I don't (as yet) see a need for any patch to these. Someone correct me 
if I'm
missing something.

<...snip...>

-- 
This is my day job. Follow me at:
IG/Twitter/Facebook: @grhookphoto
IG/Twitter/Facebook: @grhphotographer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
