Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 28DCE6B0186
	for <linux-mm@kvack.org>; Thu, 14 May 2009 04:27:02 -0400 (EDT)
Date: Thu, 14 May 2009 10:32:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to 64 bits in X86_64
Message-ID: <20090514083250.GD19296@one.firstfloor.org>
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <87zldhl7ne.fsf@basil.nowhere.org> <200905141145.05591.sheng@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200905141145.05591.sheng@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: Sheng Yang <sheng@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

> Well, I just think lots of "#ifdef/#else" is a little annoying here, then use 
> REX...

Better add a 'q' string concatination then. The problem with rex is that most 
people can't read it even if they know assembler --  they don't know
all the details of instruction encoding.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
