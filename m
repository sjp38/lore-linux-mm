Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D12EA6B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 06:50:42 -0400 (EDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: mmotm 2010-06-03-16-36 lots of suspected kmemleak
References: <AANLkTilb4QNYznFeJVfMmvPAlBY-B02EY0i0d7NK9X7O@mail.gmail.com>
Date: Fri, 04 Jun 2010 11:50:34 +0100
In-Reply-To: <AANLkTilb4QNYznFeJVfMmvPAlBY-B02EY0i0d7NK9X7O@mail.gmail.com>
	(Dave Young's message of "Fri, 4 Jun 2010 16:27:54 +0800")
Message-ID: <tnxvd9zcbr9.fsf@e102109-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Young <hidave.darkstar@gmail.com> wrote:
> With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks

Do you have CONFIG_NO_BOOTMEM enabled? I posted a patch for this but
hasn't been reviewed yet (I'll probably need to repost, so if it fixes
the problem for you a Tested-by would be nice):

http://lkml.org/lkml/2010/5/4/175

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
