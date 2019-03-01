Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B331C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 13:39:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 604B52084D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 13:39:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 604B52084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECACE8E0003; Fri,  1 Mar 2019 08:39:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E79C38E0001; Fri,  1 Mar 2019 08:39:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D69038E0003; Fri,  1 Mar 2019 08:39:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF0C8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 08:39:38 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o9so10059128edh.10
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 05:39:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=mihksJr1Oz2m4WPplxJC/HYtsN9RDpIP1YahtuUqD2Q=;
        b=LyyRbS4kACVAyB7S1ooRMKV/TytzbjvEgr7xdhNo53OVQEj4KSZZWP4t2+JPhmoXh6
         hQuR/WDGCe1qk/eLGWlITWd9O7K6bSG1hb5sEhL+9wIyOWtG8HI0cJi6Gz5VTDcLdxag
         pSkwcizmDiAd7KRqUdRZor98gdLx6fsgL0PdHhDNN6NIw59aY9ioZ2ckOTb2GdqfyNjZ
         3AQWuMEwcqsqLg/VxNp+7U9NMXNYHPO5ODgusE0DKzxSS7lPst80MKX/Rzk9zXzgWP5o
         IvFgPoH8PxrSHmf0VUMk1TM0gO9Tl8tAUZeQB3vkbqy47xyvl3qGPy0/X34mzRrWoaph
         +k9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWJ3ugiVGBQVmfF7gzqtE4Lumu8seK4iwiAJia0sTtDjwxXsAnC
	WTitWfdzDQhVjzJMcCl1Q40XlRLvMp9BYgNO39d4JX4LuSm3v/3MW3cJFKGIB/WOewKYgCdHhaI
	H6ndkCBlk2T1P1HT3G050r2GzpijjKzjT614AxnJrNXMmGn7+0AwZO6dINYd5tPFrGw==
X-Received: by 2002:a50:d8ce:: with SMTP id y14mr4246079edj.101.1551447577975;
        Fri, 01 Mar 2019 05:39:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqx7XsqaUV5nI32o33/5Mgn0lL0GYXuQNHFlLKthHoKbhJK3Kwxmf72WAcT+3tGLybUxrVQb
X-Received: by 2002:a50:d8ce:: with SMTP id y14mr4246017edj.101.1551447576769;
        Fri, 01 Mar 2019 05:39:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551447576; cv=none;
        d=google.com; s=arc-20160816;
        b=jm29XkTMOzbIZtyvCIolLgjgJ7FzeLPn+cfJOTv9d0xL40r2qYrtYBPAmyzhdQKClz
         aHxms0s3ov/HwZ0MqaVpK52RocSNbEuwgkMPN6vMErhn4eattOD6oNr27cV6TUwbvaP2
         ZQbBCQuUHIahibeN840ocIBap0T++Sr9+5z6MmDcMV9GnUO+AZPbla78br+/WZPbq+s4
         5QmLbbTmVIeIbh04oAxbVOsW8PDAbal55nZzAE5RFtqqRoI08d3f1zGP7cwke/B5zFMt
         Vy3yV39+63C4Ef6yKCy9IpMKNHEljJPNQiW0Z2uyRMNb6MY5Fh2PTmURV3kw2t2ujltD
         GTsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=mihksJr1Oz2m4WPplxJC/HYtsN9RDpIP1YahtuUqD2Q=;
        b=kbGvcTvFNAtSuBSuj/p1dxnWCAT47nhP6wFZT8rW1qhv5Ii+ALy3hVSH6ly6gtQ4Cu
         /BwuPGsJSZlrUedosN0Hm7QHQlx0TlYk9jHKIR8xM2GV5jx4OKeDuS9fgmoRElMt7Xnf
         ZbV2FfkKXEGn4HtGUT3gIwMBYWdF5jzizcXIhPNDmr1c2QvrLqeSDXfMHi2XQsgEP9s4
         uvAvpFnJoZfxAl2wjbU+0fSKnCdyM3Wqw0gcnjMzViCwtic68Y9yGLo7eYgyLuPlWstw
         fA8AI9opARLcsnfdQFcapyOawLGc/8zVGQyOpPgKgusw5R82jCsj9Czlmo3Lx+G4K0uL
         +Gjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s58si1579742edb.133.2019.03.01.05.39.36
        for <linux-mm@kvack.org>;
        Fri, 01 Mar 2019 05:39:36 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6111CA78;
	Fri,  1 Mar 2019 05:39:35 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 19B2E3F5C1;
	Fri,  1 Mar 2019 05:39:31 -0800 (PST)
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
To: "Kirill A. Shutemov" <kirill@shutemov.name>,
 Mike Rapoport <rppt@linux.ibm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
 <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
 <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
 <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
 <20190301115300.GE5156@rapoport-lnx>
 <20190301123031.rw3dswcoaa2x7haq@kshutemo-mobl1>
From: Steven Price <steven.price@arm.com>
Message-ID: <b8bd0f99-1c5e-7cf5-32dd-ab52d921e86c@arm.com>
Date: Fri, 1 Mar 2019 13:39:30 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190301123031.rw3dswcoaa2x7haq@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/03/2019 12:30, Kirill A. Shutemov wrote:
> On Fri, Mar 01, 2019 at 01:53:01PM +0200, Mike Rapoport wrote:
>> Him Kirill,
>>
>> On Fri, Feb 22, 2019 at 12:06:18AM +0300, Kirill A. Shutemov wrote:
>>> On Thu, Feb 21, 2019 at 05:16:46PM +0000, Steven Price wrote:
>>>>>> Note that in terms of the new page walking code, these new defines are
>>>>>> only used when walking a page table without a VMA (which isn't currently
>>>>>> done), so architectures which don't use p?d_large currently will work
>>>>>> fine with the generic versions. They only need to provide meaningful
>>>>>> definitions when switching to use the walk-without-a-VMA functionality.
>>>>>
>>>>> How other architectures would know that they need to provide the helpers
>>>>> to get walk-without-a-VMA functionality? This looks very fragile to me.
>>>>
>>>> Yes, you've got a good point there. This would apply to the p?d_large
>>>> macros as well - any arch which (inadvertently) uses the generic version
>>>> is likely to be fragile/broken.
>>>>
>>>> I think probably the best option here is to scrap the generic versions
>>>> altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
>>>> would enable the new functionality to those arches that opt-in. Do you
>>>> think this would be less fragile?
>>>
>>> These helpers are useful beyond pagewalker.
>>>
>>> Can we actually do some grinding and make *all* archs to provide correct
>>> helpers? Yes, it's tedious, but not that bad.
>>
>> Many architectures simply cannot support non-leaf entries at the higher
>> levels. I think letting the use a generic helper actually does make sense.
> 
> I disagree.
> 
> It's makes sense if the level doesn't exists on the arch.

This is what patch 24 [1] of the series does - if the level doesn't
exist then appropriate stubs are provided.

> But if the level exists, it will be less frugile to ask the arch to
> provide the helper. Even if it is dummy always-false.

The problem (as I see it), is we need a reliable set of p?d_large()
implementations to be able to walk arbitrary page tables. Either the
entire functionality of walking page tables without a VMA has to be an
opt-in per architecture, or we need to mandate that every architecture
provide these implementations.

I could provide an asm-generic header to provide a complete set of dummy
implementations for architectures that don't support large pages at all,
but that seems a bit overkill when most architectures only need to
define 2 or 3 implementations (the rest being provided by the
folded-levels automatically).

Thanks,

Steve

[1]
https://lore.kernel.org/lkml/20190227170608.27963-25-steven.price@arm.com/

