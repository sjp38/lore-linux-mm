Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19D88C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:54:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B72772146F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:54:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B72772146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 387E06B0005; Wed, 27 Mar 2019 08:54:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30FB36B000E; Wed, 27 Mar 2019 08:54:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D8CC6B0010; Wed, 27 Mar 2019 08:54:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0CDF6B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 08:54:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n12so6669840edo.5
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 05:54:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=QsOSkhv74cDKO5ywshCd8pRvl6x6lREXhAvQlgsVksI=;
        b=FrzxOwjBraxp8x/8SXn18zCX3eZYXKRrtB9LbK0Lg51OOMswA7kGCuCqCoqkG0PNNz
         KBzdVV3XttsDjZZ65WPgD0NUQEvH7hgOp6x/jjoYr6tQ7JaGyzaJFYKKKVQFTpwkorU2
         UHoOpkuo65r9IQqHtqh73byo3Bu5WO/5LEXEaqmLlWv4J5Qejp2OUhGzbuqFeU5K91hY
         RVQKyBAsOlZJUlldhi4U1KVlS1jzIi3trLQKftqUcjFTgfLKmtDWlTYltEIzbO0EaxSJ
         UFNhtw20vQLxAQux7Orc8q5PJSROOL8nd/IypUoFoVFg8Klq3WDWNJoSGizoEwB8FOhu
         cIQQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVmAtL1OE/6cD5qypnYBPAr3OoXJ4TrU3ftrlakjc8Wcvw2d0sn
	qWF3E/7M5E5e27yxKtAGKMJDAygsORGoPJAvpAERLzK+Kp65nL9Oxrt9hB7nOmB7oaLgwuZq20D
	dCQht7k1pcl0UD5fHJJES8Cpxt66uPHQS2eCdhwJ4rxmL8nYkhy9gXelj8QcuGc4=
X-Received: by 2002:aa7:d411:: with SMTP id z17mr15826189edq.161.1553691282329;
        Wed, 27 Mar 2019 05:54:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhVYnsNL4bI40viJ4f0WU2I6gADOJvXJB4haD/CsSx209vSnEIEVgOgh72dWAEUEu8FbdB
X-Received: by 2002:aa7:d411:: with SMTP id z17mr15826138edq.161.1553691281377;
        Wed, 27 Mar 2019 05:54:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553691281; cv=none;
        d=google.com; s=arc-20160816;
        b=QQFRrAgNwmKh1pkAZlY0W7lf6W3hGnOxbLeTWQ9sj0kjiTqnwjfWp5nkZ1RAuOtX/2
         r5n6mU5CgbrscG9m2mOYS7L66m48xQzeI1ul0Uq0OYPhFJe/GQCW+bz/EBecXEg8omFO
         3ztPlZAdWrGEdIF3oIQYHyBnYxKjUrfxKBehkQboqbWxd8KTQ+sINiT8G64GIVaXj8Cu
         GSFyeI6hk8k3NnDnpbYIiWM+om2Ikl4PR5xxrXvH4pDasInvjYyXKWLpWKwcPKWfiXZF
         Dk1/nURpqoGpAT/ZrG4ErrrrQqcZx0L00N6zGqkW58ZSTPwI/M1mjseoZtfUpS3IkEHr
         5nZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=QsOSkhv74cDKO5ywshCd8pRvl6x6lREXhAvQlgsVksI=;
        b=S50XEITopJOT+zIRRmNIMIfdm/V7zMQ0UFauS8qdAzbtQLLwGmc+RFVcBtKgVq4tjN
         cU/1XVsEct30zUBgJnCEFIIApMlLYbEk+yxzsgPob1ZBY2U6AcUcGFX7HFl5UsaeZVcS
         IzwZvBiakvyLyOIQ280IdMMz33HkZRjMwrNJFfFINvC6oUoxX4haLEjVuqmgcbPO4H1j
         D3c28TI/ctAKt5JaVEu9vAXi9Qh4fA9TFfDQVq6n/ARahiTqpd5nlrsqocTFMAgMcDVm
         frVBWjf30ytdkX5mKwBFGJ72XP7o/ArClRgADaxs69WXztZ8lXDux0g8+OOtWFIkSKkV
         iilA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id m17si242643ejb.31.2019.03.27.05.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 05:54:41 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id 4CC6A20000A;
	Wed, 27 Mar 2019 12:54:35 +0000 (UTC)
Subject: Re: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, mpe@ellerman.id.au,
 Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190327063626.18421-1-alex@ghiti.fr>
 <20190327063626.18421-5-alex@ghiti.fr>
 <f6e74ad8-acca-3b1e-27eb-a2881ac8437d@linux.ibm.com>
 <fbae7220-2e6f-8516-cf93-fbe430452043@ghiti.fr>
 <aabfc780-1681-c69a-9927-4645d6499984@linux.ibm.com>
 <e7637427-5f17-b4f4-93a2-70cac9b3a264@ghiti.fr>
 <87pnqcws2u.fsf@linux.ibm.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <95819dc9-7910-f273-681c-a241fee62dd2@ghiti.fr>
Date: Wed, 27 Mar 2019 13:54:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <87pnqcws2u.fsf@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/27/2019 11:05 AM, Aneesh Kumar K.V wrote:
> Alexandre Ghiti <alex@ghiti.fr> writes:
>
>> On 03/27/2019 09:55 AM, Aneesh Kumar K.V wrote:
>>> On 3/27/19 2:14 PM, Alexandre Ghiti wrote:
>>>>
>>>> On 03/27/2019 08:01 AM, Aneesh Kumar K.V wrote:
>>>>> On 3/27/19 12:06 PM, Alexandre Ghiti wrote:
> .....
>
>>> This is now
>>> #define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
>>> static inline bool gigantic_page_runtime_supported(void)
>>> {
>>> if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
>>>          return false;
>>>
>>>      return true;
>>> }
>>>
>>>
>>> I am wondering whether it should be
>>>
>>> #define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
>>> static inline bool gigantic_page_runtime_supported(void)
>>> {
>>>
>>>     if (!IS_ENABLED(CONFIG_CONTIG_ALLOC))
>>>          return false;
>> I don't think this test should happen here, CONFIG_CONTIG_ALLOC only allows
>> to allocate gigantic pages, doing that check here would prevent powerpc
>> to free boottime gigantic pages when not a guest. Note that this check
>> is actually done in set_max_huge_pages.
>>
>>
>>> if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
>>>          return false;
>> Maybe I did not understand this check: I understood that, in the case
>> the system
>> is virtualized, we do not want it to hand back gigantic pages. Does this
>> check
>> test if the system is currently being virtualized ?
>> If yes, I think the patch is correct: it prevents freeing gigantic pages
>> when the system
>> is virtualized but allows a 'normal' system to free gigantic pages.
>>
>>
> Ok double checked the patch applying the the tree. I got confused by the
> removal of that #ifdef. So we now disallow the runtime free by checking
> for gigantic_page_runtime_supported() in  __nr_hugepages_store_common.
> Now if we allow and if CONFIG_CONTIG_ALLOC is disabled, we still should
> allow to free the boot time allocated pages back to buddy.
>
> The patch looks good. You can add for the series
>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>
> -aneesh
>

Thanks for your time Aneesh,

Alex

