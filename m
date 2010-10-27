Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF506B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 05:09:18 -0400 (EDT)
Date: Wed, 27 Oct 2010 11:09:03 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] Please pull hwpoison updates for 2.6.37
Message-ID: <20101027090903.GA16957@elte.hu>
References: <20101026100923.GA5118@basil.fritz.box>
 <20101027074254.GA809@elte.hu>
 <20101027075846.GA2472@basil.fritz.box>
 <20101027081853.GA20196@elte.hu>
 <20101027090128.GC2472@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101027090128.GC2472@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, x86@kernel.org
List-ID: <linux-mm.kvack.org>


* Andi Kleen <andi@firstfloor.org> wrote:

> > You are welcome! How about the cleanliness feedback that i gave?
> > (the stuff in parentheses)
> 
> Could move the ifdef into mm.h for the flags and let the optimizer
> eliminate the code. I can do that in a followup patch.

Yeah. If it does not work out due to architectural differences then
do not push it too hard (the code is small enough) - we only want to
factor this out if it makes things cleaner.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
