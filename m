Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 167766B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 10:51:13 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so97714853pac.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 07:51:12 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id kw9si1718832pab.219.2015.02.03.07.51.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 07:51:11 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id et14so97716648pad.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 07:51:11 -0800 (PST)
Date: Wed, 4 Feb 2015 00:51:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
Message-ID: <20150203155103.GB2644@blaptop>
References: <20150107172452.GA7922@node.dhcp.inet.fi>
 <20150114152225.GB31484@google.com>
 <20150114233630.GA14615@node.dhcp.inet.fi>
 <alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com>
 <CA+yH71fNZSYVf1G+UUp3N6BhPhT0VJ4aGY=uPGbSD2raV55E3Q@mail.gmail.com>
 <alpine.DEB.2.10.1501221523390.27807@chino.kir.corp.google.com>
 <CA+yH71e2ewvA41BNyb=TTPn+yx2zWzY6rn09hRVVgWKoeMgwXQ@mail.gmail.com>
 <alpine.DEB.2.10.1501261552440.29252@chino.kir.corp.google.com>
 <20150203032628.GA4006@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203032628.GA4006@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Cermak <petrcermak@chromium.org>
Cc: David Rientjes <rientjes@google.com>, Primiano Tucci <primiano@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Hugh Dickins <hughd@google.com>

Hello,

On Tue, Feb 03, 2015 at 03:26:28AM +0000, Petr Cermak wrote:
> On Mon, Jan 26, 2015 at 04:00:20PM -0800, David Rientjes wrote:
> > [...]
> > This is a result of allowing something external (process B) be able to
> > clear hwm so that you never knew the value went to 100MB.  That's the
> > definition of a race, I don't know how to explain it any better and making
> > any connection between clearing PG_referenced and mm->hiwater_rss is a
> > stretch.  This approach just makes mm->hiwater_rss meaningless.
> 
> I understand your concern, but I hope you agree that the functionality we
> are proposing would be very useful for profiling. Therefore, I suggest
> adding an extra resettable field to /proc/pid/status (e.g.
> resettable_hiwater_rss) instead. What is your view on this approach?

The idea would be very useful for measuring working set size for
efficient memory management in userside, which becomes very popular
with many platforms for embedded world with tight memory.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
