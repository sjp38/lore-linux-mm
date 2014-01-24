Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9D16B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:23:07 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id d7so1178367bkh.20
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 06:23:06 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id k2si3264959bkr.9.2014.01.24.06.23.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 06:23:06 -0800 (PST)
Received: by mail-lb0-f177.google.com with SMTP id z5so2530415lbh.22
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 06:23:05 -0800 (PST)
Date: Fri, 24 Jan 2014 18:23:03 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Ignore VM_SOFTDIRTY on VMA merging, v2
Message-ID: <20140124142303.GJ1992@moon>
References: <20140122191928.GQ1574@moon>
 <20140122223325.GA30637@moon>
 <20140123095541.GD4963@suse.de>
 <20140123103606.GU1574@moon>
 <20140123121555.GV1574@moon>
 <20140123125543.GW1574@moon>
 <20140123151445.GX1574@moon>
 <20140124101416.GP4963@suse.de>
 <20140124115629.GI1992@moon>
 <20140124134135.GW4963@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140124134135.GW4963@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, gnome@rvzt.net, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Fri, Jan 24, 2014 at 01:41:35PM +0000, Mel Gorman wrote:
> > 
> > Thanks a huge, Mel! Andrew has picked it up and CC'ed stable@ team.
> 
> Big thanks to the gimp developers that actually pinned this down as a
> kernel bug and the people who shoved it through the kernel bugzilla. I
> just did a light bit of legwork shuffling the paperwork around :P

Sure! The help in testing and finding kernel problem is always invaluable!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
