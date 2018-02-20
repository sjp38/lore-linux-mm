Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2653C6B0007
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 07:52:52 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id t2so7783297plr.15
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 04:52:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v4-v6si2592581plz.143.2018.02.20.04.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Feb 2018 04:52:50 -0800 (PST)
Date: Tue, 20 Feb 2018 04:52:46 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: zsmalloc: Replace return type int with bool
Message-ID: <20180220125246.GB21243@bombadil.infradead.org>
References: <20180219194216.GA26165@jordon-HP-15-Notebook-PC>
 <201802201156.4Z60eDwx%fengguang.wu@intel.com>
 <CAFqt6zagwbvs06yK6KPp1TE5Z-mXzv6Bh2rhFFAyjz3Nh0BXmA@mail.gmail.com>
 <20180220090820.GA153760@rodete-desktop-imager.corp.google.com>
 <CAFqt6zZeiU9uMq0kNJRBs_aBTmHvZZkaotJ6GnVOjT6Y3nyS9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZeiU9uMq0kNJRBs_aBTmHvZZkaotJ6GnVOjT6Y3nyS9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Nitin Gupta <ngupta@vflare.org>, sergey.senozhatsky.work@gmail.com, Linux-MM <linux-mm@kvack.org>

On Tue, Feb 20, 2018 at 04:25:15PM +0530, Souptick Joarder wrote:
> On Tue, Feb 20, 2018 at 2:38 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Yub, bool could be more appropriate. However, there are lots of other places
> > in kernel where use int instead of bool.
> > If we fix every such places with each patch, it would be very painful.
> > If you believe it's really worth, it would be better to find/fix every
> > such places in one patch. But I'm not sure it's worth.
> >
> 
> Sure, I will create patch series and send it.

Please don't.  If you're touching a function for another reason, it's
fine to convert it to return bool.  A series of patches converting every
function in the kernel that could be converted will not make friends.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
