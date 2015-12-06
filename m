Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 60E1D6B025A
	for <linux-mm@kvack.org>; Sun,  6 Dec 2015 13:32:33 -0500 (EST)
Received: by wmww144 with SMTP id w144so116049656wmw.1
        for <linux-mm@kvack.org>; Sun, 06 Dec 2015 10:32:32 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id k6si25176924wjy.213.2015.12.06.10.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Dec 2015 10:32:32 -0800 (PST)
Date: Sun, 6 Dec 2015 19:32:31 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: tmpfs sizing broken in 4.4-rc*
Message-ID: <20151206183231.GA21661@two.firstfloor.org>
References: <20151206181655.GM15533@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151206181655.GM15533@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: hughd@google.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Dec 06, 2015 at 07:16:55PM +0100, Andi Kleen wrote:
> 
> Hi,
> 
> It seems on 4.4-rc2 something is wrong how tmpfs is sized by default.
> 
> On a 4GB system with /tmp as tmpfs I only have an 1MB sized /tmp now. Which
> breaks a lot of stuff, including the scripts to install new kernels.
> 
> When I remount it manually with a larger size things works again.
> 
> I haven't tried to bisect or debug it, but I'm reasonably sure the
> problem wasn't there with 4.3.

Never mind. I did some more experiments and tmp seems to be back
to the expected size now after some experiments/reboots. Must have been some
fluke or a rogue script.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
