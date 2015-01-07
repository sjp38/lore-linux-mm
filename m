Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5416B0038
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 06:37:07 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id z11so897148lbi.24
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 03:37:06 -0800 (PST)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id jl3si2223903lbc.36.2015.01.07.03.37.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 03:37:05 -0800 (PST)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Y8ooO-0007po-Q5
	for linux-mm@kvack.org; Wed, 07 Jan 2015 12:30:04 +0100
Received: from p4ff58476.dip0.t-ipconnect.de ([79.245.132.118])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 12:30:04 +0100
Received: from holger.hoffstaette by p4ff58476.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 12:30:04 +0100
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: Dirty pages underflow on 3.14.23
Date: Wed, 7 Jan 2015 10:57:46 +0000 (UTC)
Message-ID: <pan.2015.01.07.10.57.46@googlemail.com>
References: 
	<alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com>
	<20150106150250.GA26895@phnom.home.cmpxchg.org>
	<alpine.LRH.2.02.1501061246400.16437@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Tue, 06 Jan 2015 12:54:43 -0500, Mikulas Patocka wrote:

> On Tue, 6 Jan 2015, Johannes Weiner wrote:
> 
>> > The bug probably happened during git pull or apt-get update, though
>> > one can't be sure that these commands caused it.
>> > 
>> > I see that 3.14.24 containes some fix for underflow (commit
>> > 6619741f17f541113a02c30f22a9ca22e32c9546, upstream commit
>> > abe5f972912d086c080be4bde67750630b6fb38b), but it doesn't seem that
>> > that commit fixes this condition. If you have a commit that could fix
>> > this, say it.
>> 
>> That's an unrelated counter, but there is a known dirty underflow
>> problem that was addressed in 87a7e00b206a ("mm: protect
>> set_page_dirty() from ongoing truncation").  It should make it into the
>> stable kernels in the near future.  Can you reproduce this issue?
>> 
>> Thanks,
>> Johannes
> 
> I can't reprodce it. It happened just once.
> 
> That patch is supposed to fix an occasional underflow by a single page -
> while my meminfo showed underflow by 22952KiB (5738 pages).

You are probably looking for:
commit 835f252c6debd204fcd607c79975089b1ecd3472
"aio: fix uncorrent dirty pages accouting when truncating AIO ring buffer"

It definitely went into 3.14.26, don't know about 3.16.x.

-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
