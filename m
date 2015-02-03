Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id B3F896B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 22:26:43 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id l61so42518819wev.8
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 19:26:43 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id d9si40630746wjs.138.2015.02.02.19.26.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 19:26:42 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id y19so42184730wgg.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 19:26:41 -0800 (PST)
Date: Tue, 3 Feb 2015 03:26:28 +0000
From: Petr Cermak <petrcermak@chromium.org>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
Message-ID: <20150203032628.GA4006@google.com>
References: <20150107172452.GA7922@node.dhcp.inet.fi>
 <20150114152225.GB31484@google.com>
 <20150114233630.GA14615@node.dhcp.inet.fi>
 <alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com>
 <CA+yH71fNZSYVf1G+UUp3N6BhPhT0VJ4aGY=uPGbSD2raV55E3Q@mail.gmail.com>
 <alpine.DEB.2.10.1501221523390.27807@chino.kir.corp.google.com>
 <CA+yH71e2ewvA41BNyb=TTPn+yx2zWzY6rn09hRVVgWKoeMgwXQ@mail.gmail.com>
 <alpine.DEB.2.10.1501261552440.29252@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1501261552440.29252@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Primiano Tucci <primiano@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Hugh Dickins <hughd@google.com>

On Mon, Jan 26, 2015 at 04:00:20PM -0800, David Rientjes wrote:
> [...]
> This is a result of allowing something external (process B) be able to
> clear hwm so that you never knew the value went to 100MB.  That's the
> definition of a race, I don't know how to explain it any better and making
> any connection between clearing PG_referenced and mm->hiwater_rss is a
> stretch.  This approach just makes mm->hiwater_rss meaningless.

I understand your concern, but I hope you agree that the functionality we
are proposing would be very useful for profiling. Therefore, I suggest
adding an extra resettable field to /proc/pid/status (e.g.
resettable_hiwater_rss) instead. What is your view on this approach?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
