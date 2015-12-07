Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1336F4402F0
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 13:26:38 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so128699096pac.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 10:26:37 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id x15si2924213pfi.68.2015.12.07.10.26.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 10:26:37 -0800 (PST)
Received: by pfbg73 with SMTP id g73so70542517pfb.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 10:26:37 -0800 (PST)
Subject: Re: [PATCH v5 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
References: <1449000658-11475-1-git-send-email-dcashman@android.com>
 <1449000658-11475-4-git-send-email-dcashman@android.com>
 <56655EC8.6030905@nvidia.com> <1720878.JdEcLd8bhL@wuerfel>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <5665CF5A.1090207@android.com>
Date: Mon, 7 Dec 2015 10:26:34 -0800
MIME-Version: 1.0
In-Reply-To: <1720878.JdEcLd8bhL@wuerfel>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Jon Hunter <jonathanh@nvidia.com>
Cc: linux-kernel@vger.kernel.org, dcashman@google.com, linux-doc@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, aarcange@redhat.com, linux@arm.linux.org.uk, corbet@lwn.net, xypron.glpk@gmx.de, x86@kernel.org, hecmargi@upv.es, mgorman@suse.de, rientjes@google.com, bp@suse.de, nnk@google.com, dzickus@redhat.com, keescook@chromium.org, jpoimboe@redhat.com, tglx@linutronix.de, n-horiguchi@ah.jp.nec.com, linux-arm-kernel@lists.infradead.org, salyzyn@android.com, ebiederm@xmission.com, jeffv@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com

On 12/07/2015 03:13 AM, Arnd Bergmann wrote:
> On Monday 07 December 2015 10:26:16 Jon Hunter wrote:
>>
>> diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
>> index af461b935137..e59a75a308bc 100644
>> --- a/arch/arm64/mm/mmap.c
>> +++ b/arch/arm64/mm/mmap.c
>> @@ -51,7 +51,7 @@ unsigned long arch_mmap_rnd(void)
>>  {
>>         unsigned long rnd;
>>  
>> -ifdef CONFIG_COMPAT
>> +#ifdef CONFIG_COMPAT

Thank you Jon.  This ought to persuade me to do a final build against
the final patch, rather than the ugly porting I had been doing.  I'll
include this in v6. (how embarassing =/)

>>         if (test_thread_flag(TIF_32BIT))
>>                 rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
>>         else
>>
>> Cheers
>>
> 
> Ideally we'd remove the #ifdef around the mmap_rnd_compat_bits declaration
> and change this code to use
> 
> 	if (IS_ENABLED(CONFIG_COMPAT) && test_thread_flag(TIF_32BIT))
> 
> 	Arnd

That would result in "undefined reference to mmap_rnd_compat_bits" in
the not-defined case, no?

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
