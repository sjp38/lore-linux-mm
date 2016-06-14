Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16B8B6B0293
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 05:08:17 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id jf8so59808961lbc.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 02:08:17 -0700 (PDT)
Received: from smtprelay03.ispgateway.de (smtprelay03.ispgateway.de. [80.67.29.7])
        by mx.google.com with ESMTPS id gu6si9253292wjb.54.2016.06.14.02.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 02:08:15 -0700 (PDT)
Date: Tue, 14 Jun 2016 11:08:09 +0200
From: M G Berberich <berberic@fmi.uni-passau.de>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code]
Message-ID: <20160614090809.GA6723@invalid>
References: <Pine.LNX.4.44L0.1606091410580.1353-100000@iolanthe.rowland.org>
 <50F437E3-85F7-4034-BAAE-B2558173A2EA@gmail.com>
 <20160613130651.GA8662@invalid>
 <CAHMfzJktLSPZuLJ0R90Zaa6tj+awX9NDO2DPzjxEEJuY0CFV+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHMfzJktLSPZuLJ0R90Zaa6tj+awX9NDO2DPzjxEEJuY0CFV+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Morrison <mad@cs.technion.ac.il>
Cc: Nadav Amit <nadav.amit@gmail.com>, iommu@lists.linux-foundation.org, USB list <linux-usb@vger.kernel.org>, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>

Hello,

Am Montag, den 13. Juni schrieb Adam Morrison:
> On Mon, Jun 13, 2016 at 4:06 PM, M G Berberich
> <berberic@fmi.uni-passau.de> wrote:
> 
> > Hello,
> >
> >> >> With 4.7-rc2, after detecting a USB Mass Storage device
> >> >>
> >> >>  [   11.589843] usb-storage 4-2:1.0: USB Mass Storage device detected
> >> >>
> >> >> a constant flow of kernel-BUGS is reported (several per second).
> >
> > [a?|]
> >
> >> > This looks like a bug in the memory management subsystem.  It should be
> >> > reported on the linux-mm mailing list (CC'ed).
> >>
> >> This bug is IOMMU related (mailing list CCa??ed) and IIUC already fixed.
> >
> > Not fixed in 4.7-rc3
> 
> These patches should fix the issue:
> 
>     https://lkml.org/lkml/2016/6/1/310
>     https://lkml.org/lkml/2016/6/1/311

FYIO: They do, indeed.

> I'm not sure why they weren't applied... will ping the maintainers.

	MfG
	bmg

-- 
a??Des is vA?llig wurscht, was heut beschlos- | M G Berberich
 sen wird: I bin sowieso dagegn!a??          | mail@m-berberich.de
(SPD-Stadtrat Kurt Schindler; Regensburg)  | 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
