Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 960A56B004D
	for <linux-mm@kvack.org>; Thu, 28 May 2009 00:37:12 -0400 (EDT)
Received: from mlsv6.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id BBC2337C87
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:37:45 +0900 (JST)
Message-ID: <4A1E1512.1080603@hitachi.com>
Date: Thu, 28 May 2009 13:37:38 +0900
From: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [0/16] POISON: Intro
References: <20090407509.382219156@firstfloor.org>
    <4A1BE58A.9060708@hitachi.com> <20090526132914.GF846@one.firstfloor.org>
In-Reply-To: <20090526132914.GF846@one.firstfloor.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> On Tue, May 26, 2009 at 09:50:18PM +0900, Hidehiro Kawai wrote:
> 
>>I believe people concerning high reliable system are expecting
>>this kind of functionality.
>>But I wonder why this patch set (including former MCE improvements
>>patches) has not been merged into any subsystem trees yet.
> 
>>What is the problem?  Because of the deadlock bug and the ref counter

> There was some work recently on fixing problems found in the
> hwpoison code during further review (me with Fengguang Wu). 
> I'm hoping to do a repost with all the fixes soon
> and then it's a mm candidate and hopefully ready for merge really soon.

Thank you, Andi.

>>If so, I'd like to try to narrow down the problems or review
>>patches (although I'm afraid I'm not so skillful).
> 
> Sure any review or additional testing is welcome.
> 
> I wanted to do full reposts this week anyways, so you
> can start from there again.

OK, I'll do that.
 
>>BTW, I looked over this patch set, and I couldn't
>>find any problems except for one minor point.  I'll post
>>a comment about it later.  It is very late, but better than nothing.
> 
> Great. Thanks. Can I add your Reviewed-by tags then?

Yes, of course.

Reviewed-by: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
-- 
Hidehiro Kawai
Hitachi, Systems Development Laboratory
Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
