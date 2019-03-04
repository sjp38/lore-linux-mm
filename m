Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC4C9C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 14:36:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67BDB20823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 14:36:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67BDB20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEF748E0003; Mon,  4 Mar 2019 09:36:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E77968E0001; Mon,  4 Mar 2019 09:36:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3F508E0003; Mon,  4 Mar 2019 09:36:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA308E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 09:36:04 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m25so2759441edd.6
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 06:36:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=I2Zjk9joDLW6Z6g+6neoh3PoptY1nPlRSJxJm2BRUkM=;
        b=KwbNLkDF94PxcznH1/f+IRMv7D1MZG+pofmeiPgqPU14Ip+BzHbZZNfTn2O3sUqtW1
         7J0wzsmeXJUtX/qVHUyJ7MneS8GTe490k4TPcFFSkCM8Mjp6iB3wEHm35nCJq7VBwJMn
         bBEXqm2UosM4Wi8HbvfeP8a0kos2ZN9XOXFAxVwQNNZVR/IBAFmCB/Vh9YQKfWZCQXe3
         JL7phWv5KUQETnkwuciAq7OPR8FbHiGY7osZmfdn0HYXrDecer6/bvbGgyOsXnmpQKVr
         pbMDC7gT03t5lXWWZqgmVhYIALYa2CWQRV69FsUr8sWD8gywAGLCs5GqPyFY9nSDT5Fu
         PIvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVH+ETwI9lesprhHi9E6k9pOLBSsXAs0Ct4k4aaJ0HXYnVikk9+
	+3tnCUftWNIZxxj2wNgkPyyEcsKHHf5eLOcqxZfarYWRN2YU0iLPjpKwptvnyp+0xQKTiJRDE3X
	fzr3/5WYZ9ZKgXVm7k44YGe6JAyOh3F1zStry7fBNkQU0W1eojZLtYHr44U3OIzk0mw==
X-Received: by 2002:a50:ed0b:: with SMTP id j11mr15585116eds.102.1551710164057;
        Mon, 04 Mar 2019 06:36:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqwJBB/sqHVwfETn1DJRyPz73NroB6gaQMhOqO8faQjGUDMF16iynDgm3adoOcJSFo5O2SU8
X-Received: by 2002:a50:ed0b:: with SMTP id j11mr15585055eds.102.1551710163012;
        Mon, 04 Mar 2019 06:36:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551710163; cv=none;
        d=google.com; s=arc-20160816;
        b=Bi/Ulyclr0KEZjaPXLg0U8v02ugPUK4lwh+S3QS+1S6RXrIBy6FO/ZFl1rwhHlhVLd
         d/pA04ni3EaIoCJ0L3lH3MSiyuAMiET3+2Dv2YcN/s+xgR1cKLiYUfYzMeinTjGT2ChZ
         yjFv8EP+22Hd3/X7c/Hcye7Oxynn5AIRHGyxjGwf8gHQVBBQZfOTXeq72qFcYwnD5a9T
         lQN+Y9CHjZVSyQe7WwKCZhL2g1krtOEsgGemeIsYVdWvzJEho4B00f3x1uit+OlU+q+C
         yyReII514U0pFigWZjfWWTHJbl2MmDXiB92vIH7u+3pBOcok70pMBgHWyynad1dtF0cS
         DKFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=I2Zjk9joDLW6Z6g+6neoh3PoptY1nPlRSJxJm2BRUkM=;
        b=g3mbcJUMtB4ZwU6Dki1N3T4eubNZAd/iCbKdC+9hlpvb/r3Wt5UBxYjnsp3CTgkbLJ
         AhX9k6Hx5oXDFB+i4Q4I7pcTf4amuAEq97/9MQJuOEaCVr+P75KgunF1ukDquberkhqd
         JQwzrUwT6P96YxPupxFnWjaVSF/B1zj7kkX52aHTiHwB6jS5+ZhIHdnQAty5OS6ntmVf
         T/nydy60dt2MpkGHv77FJaJjU/dNcR7PsfBDDc9ak/UR8i8kIExJi9YdGKlsoDvx0VUg
         VUFCYvfgz7sYy0btIi4Pb0nd4CkhMmH0lcHua/1QOZ+/IlzpmcQILxlEL71Lu2j1VfFV
         6VUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g51si2315711edb.270.2019.03.04.06.36.02
        for <linux-mm@kvack.org>;
        Mon, 04 Mar 2019 06:36:03 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9EB00EBD;
	Mon,  4 Mar 2019 06:36:01 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5EA493F575;
	Mon,  4 Mar 2019 06:35:58 -0800 (PST)
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, James Morse
 <james.morse@arm.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 "Kirill A. Shutemov" <kirill@shutemov.name>,
 Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org,
 "Liang, Kan" <kan.liang@linux.intel.com>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
 <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
 <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
 <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
 <20190301115300.GE5156@rapoport-lnx>
 <20190301123031.rw3dswcoaa2x7haq@kshutemo-mobl1>
 <b8bd0f99-1c5e-7cf5-32dd-ab52d921e86c@arm.com>
 <20190303071253.GA7585@rapoport-lnx>
From: Steven Price <steven.price@arm.com>
Message-ID: <2adbc516-3ffd-8e34-887a-843ccab72d51@arm.com>
Date: Mon, 4 Mar 2019 14:35:56 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190303071253.GA7585@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/03/2019 07:12, Mike Rapoport wrote:
> On Fri, Mar 01, 2019 at 01:39:30PM +0000, Steven Price wrote:
>> On 01/03/2019 12:30, Kirill A. Shutemov wrote:
>>> On Fri, Mar 01, 2019 at 01:53:01PM +0200, Mike Rapoport wrote:
>>>> Him Kirill,
>>>>
>>>> On Fri, Feb 22, 2019 at 12:06:18AM +0300, Kirill A. Shutemov wrote:
>>>>> On Thu, Feb 21, 2019 at 05:16:46PM +0000, Steven Price wrote:
>>>>>>>> Note that in terms of the new page walking code, these new defines are
>>>>>>>> only used when walking a page table without a VMA (which isn't currently
>>>>>>>> done), so architectures which don't use p?d_large currently will work
>>>>>>>> fine with the generic versions. They only need to provide meaningful
>>>>>>>> definitions when switching to use the walk-without-a-VMA functionality.
>>>>>>>
>>>>>>> How other architectures would know that they need to provide the helpers
>>>>>>> to get walk-without-a-VMA functionality? This looks very fragile to me.
>>>>>>
>>>>>> Yes, you've got a good point there. This would apply to the p?d_large
>>>>>> macros as well - any arch which (inadvertently) uses the generic version
>>>>>> is likely to be fragile/broken.
>>>>>>
>>>>>> I think probably the best option here is to scrap the generic versions
>>>>>> altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
>>>>>> would enable the new functionality to those arches that opt-in. Do you
>>>>>> think this would be less fragile?
>>>>>
>>>>> These helpers are useful beyond pagewalker.
>>>>>
>>>>> Can we actually do some grinding and make *all* archs to provide correct
>>>>> helpers? Yes, it's tedious, but not that bad.
>>>>
>>>> Many architectures simply cannot support non-leaf entries at the higher
>>>> levels. I think letting the use a generic helper actually does make sense.
>>>
>>> I disagree.
>>>
>>> It's makes sense if the level doesn't exists on the arch.
>>
>> This is what patch 24 [1] of the series does - if the level doesn't
>> exist then appropriate stubs are provided.
>>
>>> But if the level exists, it will be less frugile to ask the arch to
>>> provide the helper. Even if it is dummy always-false.
>>
>> The problem (as I see it), is we need a reliable set of p?d_large()
>> implementations to be able to walk arbitrary page tables. Either the
>> entire functionality of walking page tables without a VMA has to be an
>> opt-in per architecture, or we need to mandate that every architecture
>> provide these implementations.
> 
> I agree that we need a reliable set of p?d_large(), but I'm still not
> convinced that every architecture should provide these.
> 
> Why having generic versions if p?d_large() is more fragile, than e.g.
> p??__access_permitted() or atomic ops?

Personally I feel having p?d_large implemented for each arch has the
following benefits:

 * Matches p?d_present/p?d_none/p?d_bad which all similarly have to be
implemented for all arches except for folded levels (when folded using
the generic code).

 * Gives the architecture maintainers a heads-up and an opportunity to
ensure that the implementations I've written are correct rather than
silently picking up the generic version.

 * When adding a new architecture it will be obvious that p?d_large
implementations are needed.

The benefits of having a generic version seem to be:

 * No boiler plate for the architectures that don't support large pages
(saves a handful of lines).

 * Easier to merge (fewer patches).

While the last one is certainly appealing (to me at least), I'm not
convinced the benefits of the generic version outweigh those of
providing implementations per-arch.

Am I missing something?

> IMHO, adding those functions/macros for architectures that support large
> pages and providing defines to avoid override of 'static inline' implementations
> would be robust enough and will avoid unnecessary stubs in architectures
> that don't have large pages.

Clearly at run time there's no difference in the "robustness" - the code
generation should be the same. So it's purely down to development processes.

However, if you prefer I can resurrect the generic versions and drop the
patches that simply add dummy implementations.

Steve

