Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C97DB6B00CC
	for <linux-mm@kvack.org>; Wed, 13 May 2009 04:37:59 -0400 (EDT)
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to 64 bits in X86_64
From: Andi Kleen <andi@firstfloor.org>
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com>
Date: Wed, 13 May 2009 10:38:29 +0200
In-Reply-To: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> (Sheng Yang's message of "Wed, 13 May 2009 16:17:27 +0800")
Message-ID: <87zldhl7ne.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Sheng Yang <sheng@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Sheng Yang <sheng@linux.intel.com> writes:

> -static inline int test_and_set_bit(int nr, volatile unsigned long *addr)
> +static inline int test_and_set_bit(long int nr, volatile unsigned long *addr)
>  {
>  	int oldbit;
>  
> -	asm volatile(LOCK_PREFIX "bts %2,%1\n\t"
> +	asm volatile(LOCK_PREFIX REX_X86 "bts %2,%1\n\t"

Use btsq on 64bit, then you don't need the explicit rex prefix.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
