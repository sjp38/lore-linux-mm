Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B737D6B79A2
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 06:13:32 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so51342pfr.6
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 03:13:32 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t20si37563ply.359.2018.12.06.03.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 03:13:31 -0800 (PST)
Date: Thu, 6 Dec 2018 12:13:28 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: hide incomplete nr_indirectly_reclaimable in
 /proc/zoneinfo
Message-ID: <20181206111328.GP19891@kroah.com>
References: <20181030174649.16778-1-guro@fb.com>
 <20181129125228.GN3149@kroah.com>
 <a4495506-2dcf-922a-1b77-e915214dd041@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a4495506-2dcf-922a-1b77-e915214dd041@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Roman Gushchin <guro@fb.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Yongqin Liu <yongqin.liu@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 29, 2018 at 03:54:10PM +0100, Vlastimil Babka wrote:
> On 11/29/18 1:52 PM, Greg KH wrote:
> > On Tue, Oct 30, 2018 at 05:48:25PM +0000, Roman Gushchin wrote:
> >> BTW, in 4.19+ the counter has been renamed and exported by
> >> the commit b29940c1abd7 ("mm: rename and change semantics of
> >> nr_indirectly_reclaimable_bytes"), so there is no such a problem
> >> anymore.
> >>
> >> Cc: <stable@vger.kernel.org> # 4.14.x-4.18.x
> >> Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
> 
> ...
> 
> > I do not see this patch in Linus's tree, do you?
> > 
> > If not, what am I supposed to do with this?
> 
> Yeah it wasn't probably clear enough, but this is stable-only patch, as
> upstream avoided the (then-unknown) problem in 4.19 as part of a far
> more intrusive series. As I've said in my previous reply to this thread,
> I don't think we can backport that series to stable (e.g. it introduces
> a set of new kmalloc caches that will suddenly appear in /proc/slabinfo)
> so I think this is a case for exception from the stable rules.

Ok, now queued up, thanks.

greg k-h
