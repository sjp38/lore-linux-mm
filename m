Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E02346B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 19:26:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n89so16211338pfk.17
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 16:26:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k7si2023799pls.500.2017.11.13.16.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 16:26:24 -0800 (PST)
Subject: Re: mmotm 2017-11-10-15-56 uploaded (lib/test_find_bit.c)
References: <5a063cc8.w9SFxvjWsZNJM4HP%akpm@linux-foundation.org>
 <2ce9cf55-2b54-b6cd-fa4d-3cd0a354b5f1@infradead.org>
 <20171113161741.5feaa74b30527f05b1684d10@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <0ce3ee27-e1a9-cea0-4a57-4aea35bed5ac@infradead.org>
Date: Mon, 13 Nov 2017 16:26:18 -0800
MIME-Version: 1.0
In-Reply-To: <20171113161741.5feaa74b30527f05b1684d10@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org, Yury Norov <ynorov@caviumnetworks.com>

On 11/13/2017 04:17 PM, Andrew Morton wrote:
> On Fri, 10 Nov 2017 18:00:57 -0800 Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> On 11/10/2017 03:56 PM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2017-11-10-15-56 has been uploaded to
>>>
>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> mmotm-readme.txt says
>>>
>>> README for mm-of-the-moment:
>>>
>>> http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>>> more than once a week.
>>
>> on i386:
>>
>> ../lib/test_find_bit.c:54:2: warning: format '%ld' expects argument of type 'long int', but argument 2 has type 'cycles_t' [-Wformat=]
>> ../lib/test_find_bit.c:68:2: warning: format '%ld' expects argument of type 'long int', but argument 2 has type 'cycles_t' [-Wformat=]
>> ../lib/test_find_bit.c:82:2: warning: format '%ld' expects argument of type 'long int', but argument 2 has type 'cycles_t' [-Wformat=]
>> ../lib/test_find_bit.c:102:2: warning: format '%ld' expects argument of type 'long int', but argument 2 has type 'cycles_t' [-Wformat=]
> 
> typecasts, I guess?  We don't seem to have a %p thingy for cycles_t?

Or the patch that Arnd sent to you that uses %ull.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
