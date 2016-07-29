Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 726586B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 13:00:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so43272413wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:00:56 -0700 (PDT)
Received: from rp02.intra2net.com (rp02.intra2net.com. [62.75.181.28])
        by mx.google.com with ESMTPS id g76si4258992wmg.106.2016.07.29.10.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 10:00:55 -0700 (PDT)
From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: Re: [Bug 64121] New: [BISECTED] "mm" performance regression updating from 3.2 to 3.3
Date: Fri, 29 Jul 2016 19:00:52 +0200
Message-ID: <10604957.uBUaVx3yh1@storm>
In-Reply-To: <CA+55aFw-g0T6c3Oza8UDssdCiEhMQZHDixsBqCXU4funLsumFg@mail.gmail.com>
References: <bug-64121-27@https.bugzilla.kernel.org/> <1650204.9z6KOJWgNh@storm> <CA+55aFw-g0T6c3Oza8UDssdCiEhMQZHDixsBqCXU4funLsumFg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm <linux-mm@kvack.org>

On Wednesday, 27. July 2016 09:44:00 Linus Torvalds wrote:
> Quite frankly, 32GB of RAM on a 32-bit kernel is so crazy as to be
> ludicrous, and nobody sane will support that. Run 32-bit user space by
> all means, but the kernel needs to be 64-bit if you have more than 8GB
> of RAM.

thanks for the detailed explanation.

Upgrading to a 64-bit kernel with a 32-bit userspace is the mid-term plan 
which might turn into a short term plan given the occasional hiccup
with PAE / low memory pressure.

Something tells me there might be issues with mISDN using a 64-bit kernel 
with a 32-bit userspace since ISDN is a feature that's not used much 
nowadays either. But that should be more or less easy to solve.

-> I consider the issue "fixed" from my side.

Cheers,
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
