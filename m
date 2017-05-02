Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF336B02EE
	for <linux-mm@kvack.org>; Tue,  2 May 2017 03:44:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p133so806077wmd.17
        for <linux-mm@kvack.org>; Tue, 02 May 2017 00:44:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si14427264wre.202.2017.05.02.00.44.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 00:44:37 -0700 (PDT)
Date: Tue, 2 May 2017 09:44:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20170502074432.GB14593@dhcp22.suse.cz>
References: <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <20161129230135.GM7179@merlins.org>
 <20170502041235.zqmywvj5tiiom3jk@merlins.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170502041235.zqmywvj5tiiom3jk@merlins.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon 01-05-17 21:12:35, Marc MERLIN wrote:
> Howdy,
> 
> Well, sadly, the problem is more or less back is 4.11.0. The system doesn't really 
> crash but it goes into an infinite loop with
> [34776.826800] BUG: workqueue lockup - pool cpus=6 node=0 flags=0x0 nice=0 stuck for 33s!
> More logs: https://pastebin.com/YqE4riw0

I am seeing a lot of traces where tasks is waiting for an IO. I do not
see any OOM report there. Why do you believe this is an OOM killer
issue?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
