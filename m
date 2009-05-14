Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5CCAF6B0173
	for <linux-mm@kvack.org>; Wed, 13 May 2009 23:43:38 -0400 (EDT)
From: Sheng Yang <sheng@linux.intel.com>
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to 64 bits in X86_64
Date: Thu, 14 May 2009 11:45:05 +0800
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <87zldhl7ne.fsf@basil.nowhere.org>
In-Reply-To: <87zldhl7ne.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905141145.05591.sheng@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 13 May 2009 16:38:29 Andi Kleen wrote:
> Sheng Yang <sheng@linux.intel.com> writes:
> > -static inline int test_and_set_bit(int nr, volatile unsigned long *addr)
> > +static inline int test_and_set_bit(long int nr, volatile unsigned long
> > *addr) {
> >  	int oldbit;
> >
> > -	asm volatile(LOCK_PREFIX "bts %2,%1\n\t"
> > +	asm volatile(LOCK_PREFIX REX_X86 "bts %2,%1\n\t"
>
> Use btsq on 64bit, then you don't need the explicit rex prefix.

Hi Andi

Well, I just think lots of "#ifdef/#else" is a little annoying here, then use 
REX...

-- 
regards
Yang, Sheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
