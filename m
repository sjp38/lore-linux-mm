Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C6F636B006C
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 22:43:01 -0400 (EDT)
Message-ID: <5170AF2B.80600@linux.intel.com>
Date: Thu, 18 Apr 2013 19:42:51 -0700
From: Darren Hart <dvhart@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: bugfix for futex-key conflict when futex use hugepage
References: <OF79A40956.94F46B9C-ON48257B50.00320F73-48257B50.0036925D@zte.com.cn> <516EAF31.8000107@linux.intel.com> <516EBF23.2090600@sr71.net> <516EC508.6070200@linux.intel.com> <OF7B3DF162.973A9AD7-ON48257B51.00299512-48257B51.002C7D65@zte.com.cn> <51700475.7050102@linux.intel.com> <OFD8FA3C9D.ACFCFB28-ON48257B52.0008A691-48257B52.000C4DFB@zte.com.cn>
In-Reply-To: <OFD8FA3C9D.ACFCFB28-ON48257B52.0008A691-48257B52.000C4DFB@zte.com.cn>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhang.yi20@zte.com.cn
Cc: Dave Hansen <dave@sr71.net>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On 04/18/2013 07:13 PM, zhang.yi20@zte.com.cn wrote:
> Darren Hart <dvhart@linux.intel.com> wrote on 2013/04/18 22:34:29:
> 
>> On 04/18/2013 01:05 AM, zhang.yi20@zte.com.cn wrote:
>>>
>>> I have run futextest/performance/futex_wait for testing, 
>>>  5 times before make it long:
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 10215 Kiter/s
>>>
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 9862 Kiter/s
>>>
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 10081 Kiter/s
>>>
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 10060 Kiter/s
>>>
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 10081 Kiter/s
>>>
>>>
>>> And 5 times after make it long:
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 9940 Kiter/s
>>>
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 10204 Kiter/s
>>>
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 9901 Kiter/s
>>>
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 10152 Kiter/s
>>>
>>> futex_wait: Measure FUTEX_WAIT operations per second
>>>         Arguments: iterations=100000000 threads=256
>>> Result: 10060 Kiter/s
>>>
>>>
>>> Seems OK, is it?
>>>
>>
>> Changes appear to be in the noise, no impact with this load 
>> anyway.
>> How many CPUs on your test machine? I presume not 256?
>>
>> -- 
> 
> There are 16 CPUsGBP! and mode is:
> Intel(R) Xeon(R) CPU           C5528  @ 2.13GHz
> 
> Shall I make the number of threads as the CPUS? I test again with argument 
> '-n 16', the result is similar.

No, I just wanted to be sure you weren't running 256 threads on 1 CPU as
you wouldn't be likely to be stressing the bucket list much :-)

> BTW, have you seen the testcase in my other mail?  It seems to be rejected 
> by LKML.

Might have something to do with what appears to still be HTML email. You
really need to fix your email client.

See:  http://www.tux.org/lkml/
#12 in particular.


-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
