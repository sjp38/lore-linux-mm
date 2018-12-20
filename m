Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E37F8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:49:57 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id j24-v6so686042lji.20
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 09:49:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor6447277lfa.38.2018.12.20.09.49.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 09:49:56 -0800 (PST)
Subject: Re: [PATCH 11/12] IMA: turn ima_policy_flags into __wr_after_init
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-12-igor.stoppa@huawei.com>
 <87pntwumw6.fsf@morokweng.localdomain>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <bb8cb502-d958-c4b4-eb82-603799079b63@gmail.com>
Date: Thu, 20 Dec 2018 19:49:52 +0200
MIME-Version: 1.0
In-Reply-To: <87pntwumw6.fsf@morokweng.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.ibm.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On 20/12/2018 19:30, Thiago Jung Bauermann wrote:
> 
> Hello Igor,
> 
> Igor Stoppa <igor.stoppa@gmail.com> writes:
> 
>> diff --git a/security/integrity/ima/ima_init.c b/security/integrity/ima/ima_init.c
>> index 59d834219cd6..5f4e13e671bf 100644
>> --- a/security/integrity/ima/ima_init.c
>> +++ b/security/integrity/ima/ima_init.c
>> @@ -21,6 +21,7 @@
>>   #include <linux/scatterlist.h>
>>   #include <linux/slab.h>
>>   #include <linux/err.h>
>> +#include <linux/prmem.h>
>>
>>   #include "ima.h"
>>
>> @@ -98,9 +99,9 @@ void __init ima_load_x509(void)
>>   {
>>   	int unset_flags = ima_policy_flag & IMA_APPRAISE;
>>
>> -	ima_policy_flag &= ~unset_flags;
>> +	wr_assign(ima_policy_flag, ima_policy_flag & ~unset_flags);
>>   	integrity_load_x509(INTEGRITY_KEYRING_IMA, CONFIG_IMA_X509_PATH);
>> -	ima_policy_flag |= unset_flags;
>> +	wr_assign(ima_policy_flag, ima_policy_flag | unset_flags);
>>   }
>>   #endif
> 
> In the cover letter, you said:
> 
>> As the name implies, the write protection kicks in only after init()
>> is completed; before that moment, the data is modifiable in the usual
>> way.
> 
> Given that, is it still necessary or useful to use wr_assign() in a
> function marked with __init?

I might have been over enthusiastic of using the wr interface.
You are right, I can drop these two. Thank you.

--
igor
