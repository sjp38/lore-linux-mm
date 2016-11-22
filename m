Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 700216B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:47:17 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j65so64239446iof.1
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:47:17 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id a127si20238457iog.65.2016.11.22.08.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 Nov 2016 08:47:16 -0800 (PST)
Date: Tue, 22 Nov 2016 08:47:11 -0800
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20161122164711.5cpdl4ukr7rry4nf@merlins.org>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <20161122162544.GG6831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161122162544.GG6831@dhcp22.suse.cz>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Nov 22, 2016 at 05:25:44PM +0100, Michal Hocko wrote:
> currently AFAIR. I hate that Marc is not falling into that category but
> is it really problem for you to run with 4.9? If we have more users

Don't do anything just on my account. I had a problem, it's been fixed
in 2 different ways: 4.8+patch, or 4.9rc5

For me this was a 100% regression from 4.6, there was just no way I
could copy my data at all with 4.8, it not only failed, but killed all
the services on my machine until it randomly killed the shell that was
doing the copy.
Personally, I'll stick with 4.8 + this patch, and switch to 4.9 when
it's out (I'm a bit wary of RC kernels on a production server,
especially when I'm in the middle of trying to get my only good backup
to work again)

But at the same time, what I'm doing is probably not common (btrfs on
top of dmcrypt, on top of bcache, on top of swraid5, for both source and
destination), so I can't comment on whether the fix I just put on my 4.8
kernel does not cause other regressions or problems for other people.

Either way, I'm personally ok again now, so I thank you all for your
help, and will leave the hard decisions to you :)

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/                         | PGP 1024R/763BE901

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
