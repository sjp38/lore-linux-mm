Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 32FF36B01D1
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:36:16 -0400 (EDT)
Message-ID: <4A0C2C5F.4030008@zytor.com>
Date: Thu, 14 May 2009 07:36:15 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to
 64 bits in X86_64
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <87zldhl7ne.fsf@basil.nowhere.org> <200905141145.05591.sheng@linux.intel.com> <20090514083250.GD19296@one.firstfloor.org> <4A0C262B.3060303@zytor.com> <20090514141649.GD10933@one.firstfloor.org> <4A0C27AA.4010006@zytor.com> <20090514142749.GE10933@one.firstfloor.org> <4A0C29D2.9050101@zytor.com> <20090514143312.GF10933@one.firstfloor.org>
In-Reply-To: <20090514143312.GF10933@one.firstfloor.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Sheng Yang <sheng@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> 
> Well they have to fix a lot of more stuff then, when I did 
> all the inline assembler >2GB objects were a explicit non goal. 
> It also wouldn't surprise me if that wasn't true on other architectures too.

512 MB, fwiw...

> It would be better to just use open coded C for that case and avoid inline 
> assembler.

It's not like the extra REX prefix is going to matter significantly for
any application, and given how trivial it is it doesn't seem like a big
deal at all.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
