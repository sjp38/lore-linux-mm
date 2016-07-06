Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED85B828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 12:02:27 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ts6so463752120pac.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 09:02:27 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id m69si4770179pfc.279.2016.07.06.09.02.26
        for <linux-mm@kvack.org>;
        Wed, 06 Jul 2016 09:02:26 -0700 (PDT)
Subject: Re: [PATCH 3/4] x86: disallow running with 32-bit PTEs to work around
 erratum
References: <006001d1d5a8$dd26e1f0$9774a5d0$@alibaba-inc.com>
 <006401d1d5ab$5e154070$1a3fc150$@alibaba-inc.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <577D2B91.2030007@sr71.net>
Date: Wed, 6 Jul 2016 09:02:25 -0700
MIME-Version: 1.0
In-Reply-To: <006401d1d5ab$5e154070$1a3fc150$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 07/03/2016 09:20 PM, Hillf Danton wrote:
...
>> When we have 64-bit PTEs (64-bit mode or 32-bit PAE), we were able
>> to move the swap PTE format around to avoid these troublesome bits.
>> But, 32-bit non-PAE is tight on bits.  So, disallow it from running
>> on this hardware.  I can't imagine anyone wanting to run 32-bit
>> on this hardware, but this is the safe thing to do.
> 
> <jawoff>
> 
> Isn't this work from Mr. Tlb?

I have no idea what you mean.
>> +	if (!err)
>> +		err = check_knl_erratum();
>>
>>  	if (err_flags_ptr)
>>  		*err_flags_ptr = err ? err_flags : NULL;
>> @@ -185,3 +188,32 @@ int check_cpu(int *cpu_level_ptr, int *r
>>
>>  	return (cpu.level < req_level || err) ? -1 : 0;
>>  }
>> +
>> +int check_knl_erratum(void)
> 
> s/knl/xeon_knl/ ?

Nah.  I mean we could say xeon_phi_knl, but I don't think it's worth
worrying too much about a function called in one place and commented
heavily.

>> +	puts("This 32-bit kernel can not run on this processor due\n"
>> +	     "to a processor erratum.  Use a 64-bit kernel, or PAE.\n\n");
> 
> Give processor name to the scared readers please.

Yeah, that's a pretty good idea.  I'll be more explicit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
