Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CC36A6B01CD
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:27:23 -0400 (EDT)
Date: Thu, 14 May 2009 16:33:12 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to 64 bits in X86_64
Message-ID: <20090514143312.GF10933@one.firstfloor.org>
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <87zldhl7ne.fsf@basil.nowhere.org> <200905141145.05591.sheng@linux.intel.com> <20090514083250.GD19296@one.firstfloor.org> <4A0C262B.3060303@zytor.com> <20090514141649.GD10933@one.firstfloor.org> <4A0C27AA.4010006@zytor.com> <20090514142749.GE10933@one.firstfloor.org> <4A0C29D2.9050101@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A0C29D2.9050101@zytor.com>
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <andi@firstfloor.org>, Sheng Yang <sheng@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 07:25:22AM -0700, H. Peter Anvin wrote:
> Andi Kleen wrote:
> > 
> > Pretty much all the bit ops and a few other operations currently have
> > 2/4GB limits on x86-64. I don't think that's going to change.
> > 
> > In the kernel nothing is ever that big continuously anyways.
> > 
> 
> Uhm, that *is* the problem at hand... specifically the bootmem map on
> multi-terabyte systems.

Well they have to fix a lot of more stuff then, when I did 
all the inline assembler >2GB objects were a explicit non goal. 
It also wouldn't surprise me if that wasn't true on other architectures too.

It would be better to just use open coded C for that case and avoid inline 
assembler.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
