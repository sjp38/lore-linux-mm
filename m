Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 69FBC6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:08:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g10so5535084wrg.2
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:08:39 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f44si736625eda.61.2017.10.03.08.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:08:38 -0700 (PDT)
Subject: Re: [PATCH v9 01/12] x86/mm: setting fields in deferred pages
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-2-pasha.tatashin@oracle.com>
 <20171003122658.cv64pxnuavopjid6@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <00978c7c-8d05-fbc3-eaba-9455b66ff02e@oracle.com>
Date: Tue, 3 Oct 2017 11:07:54 -0400
MIME-Version: 1.0
In-Reply-To: <20171003122658.cv64pxnuavopjid6@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Michal,

> 
> I hope I haven't missed anything but it looks good to me.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you for your review.

> 
> one nit below
>> ---
>>   arch/x86/mm/init_64.c | 9 +++++++--
>>   1 file changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>> index 5ea1c3c2636e..30fe22558720 100644
>> --- a/arch/x86/mm/init_64.c
>> +++ b/arch/x86/mm/init_64.c
>> @@ -1182,12 +1182,17 @@ void __init mem_init(void)
>>   
>>   	/* clear_bss() already clear the empty_zero_page */
>>   
>> -	register_page_bootmem_info();
>> -
>>   	/* this will put all memory onto the freelists */
>>   	free_all_bootmem();
>>   	after_bootmem = 1;
>>   
>> +	/* Must be done after boot memory is put on freelist, because here we
> 
> standard code style is to do
> 	/*
> 	 * text starts here

OK, will change for both patch 1 and 2.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
