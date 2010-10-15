Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B1F486B0183
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 04:50:18 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Implement hwpoison on free for soft offlining
References: <1286402951-1881-1-git-send-email-andi@firstfloor.org>
Date: Fri, 15 Oct 2010 10:50:13 +0200
In-Reply-To: <1286402951-1881-1-git-send-email-andi@firstfloor.org> (Andi
	Kleen's message of "Thu, 7 Oct 2010 00:09:10 +0200")
Message-ID: <874ocnc01m.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, fengguang.wu@intel.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Andi Kleen <andi@firstfloor.org> writes:

> Here's a somewhat experimental patch to improve soft offlining
> in hwpoison, but allowing hwpoison on free for not directly
> freeable page types. It should work for nearly all
> left over page types that get eventually freed, so this makes
> soft offlining nearly universal. The only non handleable page
> types are now pages that never get freed.
>
> Drawback: It needs an additional page flag. Cannot set hwpoison
> directly because that would not be "soft" and cause errors.
>
> Since the flags are scarce on 32bit I only enabled it on 64bit.
>
> Comments?

I got a couple of positive comments and reviews and no negative comments.

So I assume noone has a problem with using up a 64bit page flag
for this. I plan to push this into linux-next after some delay
and then prepare it for merge later.

If there are any objections please speak up now.

Thanks,
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
