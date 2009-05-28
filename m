Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 555926B004F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 03:53:07 -0400 (EDT)
Date: Thu, 28 May 2009 10:00:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/16] POISON: Intro
Message-ID: <20090528080033.GZ1065@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <4A1BE58A.9060708@hitachi.com> <20090526132914.GF846@one.firstfloor.org> <4A1E1512.1080603@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A1E1512.1080603@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 01:37:38PM +0900, Hidehiro Kawai wrote:
> >>BTW, I looked over this patch set, and I couldn't
> >>find any problems except for one minor point.  I'll post
> >>a comment about it later.  It is very late, but better than nothing.
> > 
> > Great. Thanks. Can I add your Reviewed-by tags then?
> 
> Yes, of course.

Sorry I posted it before seeing your email. If you could take
a look at the updated patchkit too that would be great?

> Reviewed-by: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>

I will add that thanks.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
