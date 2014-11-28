Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 53DA26B0069
	for <linux-mm@kvack.org>; Fri, 28 Nov 2014 03:00:24 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so6422107pad.10
        for <linux-mm@kvack.org>; Fri, 28 Nov 2014 00:00:24 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id vv4si14898266pbc.165.2014.11.28.00.00.21
        for <linux-mm@kvack.org>;
        Fri, 28 Nov 2014 00:00:22 -0800 (PST)
Date: Fri, 28 Nov 2014 17:03:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141128080331.GD11802@js1304-P5Q-DELUXE>
References: <20141119012110.GA2608@cucumber.iinet.net.au>
 <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
 <20141119212013.GA18318@cucumber.anchor.net.au>
 <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Korolyov <andrey@xdel.ru>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Nov 25, 2014 at 01:48:42AM +0400, Andrey Korolyov wrote:
> On Sun, Nov 23, 2014 at 12:33 PM, Christian Marie <christian@ponies.io> wrote:
> > Here's an update:
> >
> > Tried running 3.18.0-rc5 over the weekend to no avail. A load spike through
> > Ceph brings no perceived improvement over the chassis running 3.10 kernels.
> >
> > Here is a graph of *system* cpu time (not user), note that 3.18 was a005.block:
> >
> > http://ponies.io/raw/cluster.png
> >
> > It is perhaps faring a little better that those chassis running the 3.10 in
> > that it did not have min_free_kbytes raised to 2GB as the others did, instead
> > it was sitting around 90MB.
> >
> > The perf recording did look a little different. Not sure if this was just the
> > luck of the draw in how the fractal rendering works:
> >
> > http://ponies.io/raw/perf-3.10.png
> >
> > Any pointers on how we can track this down? There's at least three of us
> > following at this now so we should have plenty of area to test.
> 
> 
> Checked against 3.16 (3.17 hanged for an unrelated problem), the issue
> is presented for single- and two-headed systems as well. Ceph-users
> reported presence of the problem for 3.17, so probably we are facing
> generic compaction issue.
> 

Hello,

I didn't follow-up this discussion, but, at glance, this excessive CPU
usage by compaction is related to following fixes.

Could you test following two patches?

If these fixes your problem, I will resumit patches with proper commit
description.

Thanks.

-------->8-------------
