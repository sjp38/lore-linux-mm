Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 68FC16B00CF
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 13:38:09 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so3491673pab.0
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 10:38:09 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id sf10si29193874pac.3.2014.11.14.10.38.07
        for <linux-mm@kvack.org>;
        Fri, 14 Nov 2014 10:38:07 -0800 (PST)
Message-ID: <54664C0B.6070604@sr71.net>
Date: Fri, 14 Nov 2014 10:38:03 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] x86, mpx: add MPX to disaabled features
References: <20141114151816.F56A3072@viggo.jf.intel.com> <20141114151823.B358EAD2@viggo.jf.intel.com> <5466425D.1060100@cogentembedded.com>
In-Reply-To: <5466425D.1060100@cogentembedded.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, dave.hansen@linux.intel.com

On 11/14/2014 09:56 AM, Sergei Shtylyov wrote:
>>   #define DISABLED_MASK6    0
>>   #define DISABLED_MASK7    0
>>   #define DISABLED_MASK8    0
>> -#define DISABLED_MASK9    0
>> +#define DISABLED_MASK9    (DISABLE_MPX)
> 
>    These parens are not really needed. Sorry to be a PITA and not saying
> this before.

One goal of the disabled features patch was to maintain parity with
required-features.h.  It declares things this way:

> #define REQUIRED_MASK3  (NEED_NOPL)
> #define REQUIRED_MASK4  (NEED_MOVBE)

So, no, those aren't strictly needed, but there is precedent for them
and they do no harm.  I think I'll leave them as-is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
