Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF56C6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:07:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y16so45251532wmd.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:07:53 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id bf6si60075849wjb.201.2016.11.29.08.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 08:07:52 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id g23so25171961wme.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:07:52 -0800 (PST)
Date: Tue, 29 Nov 2016 17:07:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20161129160751.GC9796@dhcp22.suse.cz>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue 29-11-16 07:55:37, Marc MERLIN wrote:
> On Mon, Nov 28, 2016 at 08:23:15AM +0100, Michal Hocko wrote:
> > Marc, could you try this patch please? I think it should be pretty clear
> > it should help you but running it through your use case would be more
> > than welcome before I ask Greg to take this to the 4.8 stable tree.
> 
> I ran it overnight and copied 1.4TB with it before it failed because
> there wasn't enough disk space on the other side, so I think it fixes
> the problem too.

Can I add your Tested-by?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
