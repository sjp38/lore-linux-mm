Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C5F6B6B01BF
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:10:00 -0400 (EDT)
Message-ID: <4A0C262B.3060303@zytor.com>
Date: Thu, 14 May 2009 07:09:47 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to
 64 bits in X86_64
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <87zldhl7ne.fsf@basil.nowhere.org> <200905141145.05591.sheng@linux.intel.com> <20090514083250.GD19296@one.firstfloor.org>
In-Reply-To: <20090514083250.GD19296@one.firstfloor.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Sheng Yang <sheng@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>> Well, I just think lots of "#ifdef/#else" is a little annoying here, then use 
>> REX...
> 
> Better add a 'q' string concatination then. The problem with rex is that most 
> people can't read it even if they know assembler --  they don't know
> all the details of instruction encoding.
> 

The right way to do it is to pass the proper type of register.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
