Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 85B776B0295
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 13:17:31 -0400 (EDT)
Received: by ioii196 with SMTP id i196so92912003ioi.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 10:17:31 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id y3si3146439igl.47.2015.10.01.10.17.30
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 10:17:30 -0700 (PDT)
Subject: Re: [PATCH 05/25] x86, pkey: add PKRU xsave fields and data
 structure(s)
References: <20150928191817.035A64E2@viggo.jf.intel.com>
 <20150928191819.925D0BD3@viggo.jf.intel.com>
 <alpine.DEB.2.11.1510011303420.4500@nanos>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560D6A9F.2000504@sr71.net>
Date: Thu, 1 Oct 2015 10:17:19 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1510011303420.4500@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On 10/01/2015 04:50 AM, Thomas Gleixner wrote:
> On Mon, 28 Sep 2015, Dave Hansen wrote:
>> +/*
>> + * State component 9: 32-bit PKRU register.
>> + */
>> +struct pkru {
>> +	u32 pkru;
>> +} __packed;
>> +
>> +struct pkru_state {
>> +	union {
>> +		struct pkru		pkru;
>> +		u8			pad_to_8_bytes[8];
>> +	};
> 
> Why do you need two structs?
> 
>     struct pkru_state {
>     	   u32 pkru;
> 	   u32 pad;
>     }
> 
> should be sufficient. So instead of
> 
>        xsave.pkru_state.pkru.pkru
> 
> you get the more obvious
> 
>        xsave.pkru_state.pkru
> 
> Hmm?

I was trying to get across that PKRU itself and the "PKRU state" are
differently-sized.

But, it does just end up looking funky if we _use_ it.  I'll fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
