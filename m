Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 635366B0055
	for <linux-mm@kvack.org>; Tue, 26 May 2009 08:50:01 -0400 (EDT)
Received: from mlsv8.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id BF53F37C84
	for <linux-mm@kvack.org>; Tue, 26 May 2009 21:50:46 +0900 (JST)
Message-ID: <4A1BE58A.9060708@hitachi.com>
Date: Tue, 26 May 2009 21:50:18 +0900
From: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [0/16] POISON: Intro
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

Hi all,
(I'm sorry for the very late comment.)

Andi Kleen wrote:

> Upcoming Intel CPUs have support for recovering from some memory errors. This
> requires the OS to declare a page "poisoned", kill the processes associated
> with it and avoid using it in the future. This patchkit implements
> the necessary infrastructure in the VM.

I think this patch set is a great step to get the Linux system
reliable close to mainframe.  I really appreciate your work.

I believe people concerning high reliable system are expecting
this kind of functionality.
But I wonder why this patch set (including former MCE improvements
patches) has not been merged into any subsystem trees yet.
What is the problem?  Because of the deadlock bug and the ref counter
problem?  Or are we waiting for 32bit unification to complete?
If so, I'd like to try to narrow down the problems or review
patches (although I'm afraid I'm not so skillful).

BTW, I looked over this patch set, and I couldn't
find any problems except for one minor point.  I'll post
a comment about it later.  It is very late, but better than nothing.

Regards,
-- 
Hidehiro Kawai
Hitachi, Systems Development Laboratory
Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
