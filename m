Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 59BEC6B00BD
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 04:11:07 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Implement hwpoison on free for soft offlining
References: <1286402951-1881-1-git-send-email-andi@firstfloor.org>
Date: Tue, 12 Oct 2010 10:11:04 +0200
In-Reply-To: <1286402951-1881-1-git-send-email-andi@firstfloor.org> (Andi
	Kleen's message of "Thu, 7 Oct 2010 00:09:10 +0200")
Message-ID: <87aamj3k6f.fsf@basil.nowhere.org>
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

Ping? Any comments on this patch?

Except for the page flag use I think it's nearly a no brainer. 
A lot of new soft hwpoison capability for very little additional code.

Has anyone a problem using up a 64bit page flag for that?

Thanks,

-Andi 
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
