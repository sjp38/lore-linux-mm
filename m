Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CFDDC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:37:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1C32206BB
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:36:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1C32206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A1AC6B0007; Tue, 11 Jun 2019 10:36:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8519E6B0008; Tue, 11 Jun 2019 10:36:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71A476B000A; Tue, 11 Jun 2019 10:36:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 238AF6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:36:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k22so21029894ede.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:36:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=R4/9INRI6KTX6FdVgwat0kPEuSKF7xIu6Kle38300yQ=;
        b=heoaEScuGOdbDHmPkKiQm+QT7Njk+NygqqC23eVoqBmad+k/lvFRyfRj4YN9e7v9tg
         88EVi+f+QQdGuyM4ufhJz610Y4FZY7VUWdLIS4q3JgbYze6pGp1BDwHqARexFXWwOwSg
         WXztoZCAZDtpYKu96hVjWAS3ol4fQdn643RFBfAt8Hy96SKC2ZTFodfhPY0lV7IngJ+h
         uauJMSY6nQkWJCFf+6eQoEkb0Pa7gh4gNcXZq6t7SaVlCsOI5Bm5pG3ihATzLXRmijIM
         WGy5ttAVLGosqiQf8gxHMwGe3NwDAuPxqZ51SJhWFXvAcAy9ESTE3BJm24Ssr7T0LYZF
         jJKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAXiXZkfT4jfkClq3qqQhxg0zNt1DBmVuniQ7jYnyzq5A/NV7kz2
	h7H4jOV8v4RBZEwaTGySC9Bb+HwoAJyjxmizBpqADxJLLaS6mIk9RFtskY6GITxXgVqzVredLhH
	BljOCbATL9nF6uRDsWUo2EZtMt0pVVP5JmSQVKFv0kFr3uJwjj5k9k1GMjN4UeWBjhA==
X-Received: by 2002:a50:a5f1:: with SMTP id b46mr81160658edc.167.1560263818623;
        Tue, 11 Jun 2019 07:36:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2U5Wb1H7qPaXvxcmiQb8vsGFDpZS6tj0XXF1dgWLMhDtntBmkadpf/5dW+95zy+S4QGkz
X-Received: by 2002:a50:a5f1:: with SMTP id b46mr81160489edc.167.1560263817075;
        Tue, 11 Jun 2019 07:36:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560263817; cv=none;
        d=google.com; s=arc-20160816;
        b=UXdqGIYsNtAv4CzBgtIOFNMlXidGFQYeDFChGprFRSH000mWMANbZZjj09KgKV6GOZ
         ByArjlK9iJzW6AwvBRAfO1KWHeyJg1LQ/umm2pncdE6g5BEG8TGRX9BsKsW/g/vWsUIn
         qT2Z4Iyr5ueEfnWXaPutMmMN/7scn4PSa7zhxIz9RkQJtB0YHaStTPqw31kcupXJVYBg
         SOOXGPgwtQIS69vUIQQnsbaGE0aYB3lfen/t8iviKgXmT9guLYw2OyDGjC0ChVI1EBgH
         A4xsVkAN7ldpLRYR5g/JXai+6yxN1337fIUszax1fFVWhf4NfXNeI0+OZ/1k3iWtOxjH
         huhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=R4/9INRI6KTX6FdVgwat0kPEuSKF7xIu6Kle38300yQ=;
        b=xTOldbXdYn4vSy5w9Cpfke90V9G3BQWwXBA9T1OD1n0/ONmcp/TV2TOfByKIqaWyEr
         I+wnyxQHF5bOWEXv68uOn0ladPi1QR+eRI96U1A+k7MqhvcHYBZN/28f9kT7GxI9U5eu
         UuPveGxHdiO5ALtqhTgvLJMrczwmdPRlTfaNQEtmQn5864KyCNuMiEpimeObf7SSZkpw
         PHlYCuZrmm11EQIKCRBxpCQJo2V2pYEFizHh2ib4BNsd8Ph8KH8vgSjVyW/NxWIOdRKx
         ckkBBACyhp5IluzhUXyGQLVK54uNCDzBrf+o4NzNWIBXxEujEn4Q7kWJ7K4clMFxtaZt
         J9IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 43si1292096edz.258.2019.06.11.07.36.56
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 07:36:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 093FC346;
	Tue, 11 Jun 2019 07:36:56 -0700 (PDT)
Received: from [10.1.29.141] (e121487-lin.cambridge.arm.com [10.1.29.141])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 187C33F557;
	Tue, 11 Jun 2019 07:36:54 -0700 (PDT)
Subject: Re: [PATCH 02/17] mm: stub out all of swapops.h for !CONFIG_MMU
To: Christoph Hellwig <hch@lst.de>
Cc: Palmer Dabbelt <palmer@sifive.com>, Damien Le Moal
 <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org,
 uclinux-dev@uclinux.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190610221621.10938-1-hch@lst.de>
 <20190610221621.10938-3-hch@lst.de>
 <516c8def-22db-027c-873d-a943454e33af@arm.com>
 <20190611141841.GA29151@lst.de>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <80d01a1d-b6b0-18e8-811c-71af14cba3b9@arm.com>
Date: Tue, 11 Jun 2019 15:36:53 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190611141841.GA29151@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/11/19 3:18 PM, Christoph Hellwig wrote:
> On Tue, Jun 11, 2019 at 11:15:44AM +0100, Vladimir Murzin wrote:
>> On 6/10/19 11:16 PM, Christoph Hellwig wrote:
>>> The whole header file deals with swap entries and PTEs, none of which
>>> can exist for nommu builds.
>>
>> Although I agree with the patch, I'm wondering how you get into it?
> 
> Without that the RISC-V nommu blows up like this:
> 
> 
> In file included from mm/vmscan.c:58:
> ./include/linux/swapops.h: In function ‘pte_to_swp_entry’:
> ./include/linux/swapops.h:71:15: error: implicit declaration of function ‘__pte_to_swp_entry’; did you mean ‘pte_to_swp_entry’? [-Werror=implicit-function-declaration]
>   arch_entry = __pte_to_swp_entry(pte);
>                ^~~~~~~~~~~~~~~~~~
>                pte_to_swp_entry
> ./include/linux/swapops.h:71:13: error: incompatible types when assigning to type ‘swp_entry_t’ {aka ‘struct <anonymous>’} from type ‘int’
>   arch_entry = __pte_to_swp_entry(pte);
>              ^
> ./include/linux/swapops.h:72:19: error: implicit declaration of function ‘__swp_type’; did you mean ‘swp_type’? [-Werror=implicit-function-declaration]
>   return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
>                    ^~~~~~~~~~
>                    swp_type
> ./include/linux/swapops.h:72:43: error: implicit declaration of function ‘__swp_offset’; did you mean ‘swp_offset’? [-Werror=implicit-function-declaration]
>   return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
>                                            ^~~~~~~~~~~~
>                                            swp_offset
> ./include/linux/swapops.h: In function ‘swp_entry_to_pte’:
> ./include/linux/swapops.h:83:15: error: implicit declaration of function ‘__swp_entry’; did you mean ‘swp_entry’? [-Werror=implicit-function-declaration]
>   arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
>                ^~~~~~~~~~~
>                swp_entry
> ./include/linux/swapops.h:83:13: error: incompatible types when assigning to type ‘swp_entry_t’ {aka ‘struct <anonymous>’} from type ‘int’
>   arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
>              ^
> ./include/linux/swapops.h:84:9: error: implicit declaration of function ‘__swp_entry_to_pte’; did you mean ‘swp_entry_to_pte’? [-Werror=implicit-function-declaration]
>   return __swp_entry_to_pte(arch_entry);
>          ^~~~~~~~~~~~~~~~~~
>          swp_entry_to_pte
> ./include/linux/swapops.h:84:9: error: incompatible types when returning type ‘int’ but ‘pte_t’ {aka ‘struct <anonymous>’} was expected
>   return __swp_entry_to_pte(arch_entry);
>          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> cc1: some warnings being treated as errors
> make[1]: *** [scripts/Makefile.build:278: mm/vmscan.o] Error 1
> make: *** [Makefile:1071: mm] Error 2
> make: *** Waiting for unfinished jobs....
> 

It looks like NOMMU ports tend to define those. For ARM they are:

#define __swp_type(x)           (0)
#define __swp_offset(x)         (0)
#define __swp_entry(typ,off)    ((swp_entry_t) { ((typ) | ((off) << 7)) })
#define __pte_to_swp_entry(pte) ((swp_entry_t) { pte_val(pte) })
#define __swp_entry_to_pte(x)   ((pte_t) { (x).val })

Anyway, I have no strong opinion on which is better :)

Cheers
Vladimir

