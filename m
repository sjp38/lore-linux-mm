Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5D86B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:21:52 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r94so28385915ioe.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:21:52 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id 65si48457909ioc.133.2016.11.30.10.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Nov 2016 10:21:52 -0800 (PST)
Date: Wed, 30 Nov 2016 10:21:44 -0800
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20161130182144.xhnmgpsyyv423pqw@merlins.org>
References: <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
 <20161130174713.lhvqgophhiupzwrm@merlins.org>
 <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Wed, Nov 30, 2016 at 10:14:50AM -0800, Linus Torvalds wrote:
> Anyway, none of this seems new per se. I'm adding Kent and Jens to the
> cc (Tejun already was), in the hope that maybe they have some idea how
> to control the nasty worst-case behavior wrt workqueue lockup (it's
> not really a "lockup", it looks like it's just hundreds of workqueues
> all waiting for IO to complete and much too deep IO queues).
 
I'll take your word for it, all I got in the end was
Kernel panic - not syncing: Hard LOCKUP
and the system stone dead when I woke up hours later.

> And I think your NMI watchdog then turns the "system is no longer
> responsive" into an actual kernel panic.

Ah, I see.

Thanks for the reply, and sorry for bringing in that separate thread
from the btrfs mailing list, which effectively was a suggestion similar
to what you're saying here too.

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
