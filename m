Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id AEC946B0257
	for <linux-mm@kvack.org>; Sun,  6 Dec 2015 13:16:58 -0500 (EST)
Received: by wmww144 with SMTP id w144so123865159wmw.0
        for <linux-mm@kvack.org>; Sun, 06 Dec 2015 10:16:58 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id m139si19226313wma.54.2015.12.06.10.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Dec 2015 10:16:57 -0800 (PST)
Date: Sun, 6 Dec 2015 19:16:56 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: tmpfs sizing broken in 4.4-rc*
Message-ID: <20151206181655.GM15533@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org


Hi,

It seems on 4.4-rc2 something is wrong how tmpfs is sized by default.

On a 4GB system with /tmp as tmpfs I only have an 1MB sized /tmp now. Which
breaks a lot of stuff, including the scripts to install new kernels.

When I remount it manually with a larger size things works again.

I haven't tried to bisect or debug it, but I'm reasonably sure the
problem wasn't there with 4.3.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
