Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id E90156B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 06:56:33 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id 6so1103705bkj.29
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 03:56:33 -0800 (PST)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id lh1si2791723bkb.86.2014.01.24.03.56.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 03:56:32 -0800 (PST)
Received: by mail-lb0-f176.google.com with SMTP id w7so2455032lbi.35
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 03:56:32 -0800 (PST)
Date: Fri, 24 Jan 2014 15:56:29 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Ignore VM_SOFTDIRTY on VMA merging, v2
Message-ID: <20140124115629.GI1992@moon>
References: <20140122190816.GB4963@suse.de>
 <20140122191928.GQ1574@moon>
 <20140122223325.GA30637@moon>
 <20140123095541.GD4963@suse.de>
 <20140123103606.GU1574@moon>
 <20140123121555.GV1574@moon>
 <20140123125543.GW1574@moon>
 <20140123151445.GX1574@moon>
 <20140124101416.GP4963@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140124101416.GP4963@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, gnome@rvzt.net, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Fri, Jan 24, 2014 at 10:14:16AM +0000, Mel Gorman wrote:
> > From: Cyrill Gorcunov <gorcunov@gmail.com>
> > Subject: [PATCH] mm: Ignore VM_SOFTDIRTY on VMA merging, v2
> > 
> 
> It passed the gimp launching test. Patch looks sane but I confess I did
> not put a whole lot of thought into it because I see that Andrew is
> already reviewing it so
> 
> Tested-by: Mel Gorman <mgorman@suse.de>
> 
> If this is merged then remember that it should be tagged for 3.12-stable
> as 3.12.7 and 3.12.8 are affected by this bug.

Thanks a huge, Mel! Andrew has picked it up and CC'ed stable@ team.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
