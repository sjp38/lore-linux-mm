Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 556026B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 09:07:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r5so28994621wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:07:00 -0700 (PDT)
Received: from smtprelay05.ispgateway.de (smtprelay05.ispgateway.de. [80.67.31.97])
        by mx.google.com with ESMTPS id t185si6356540wmd.88.2016.06.13.06.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 06:06:59 -0700 (PDT)
Date: Mon, 13 Jun 2016 15:06:51 +0200
From: M G Berberich <berberic@fmi.uni-passau.de>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code]
Message-ID: <20160613130651.GA8662@invalid>
References: <Pine.LNX.4.44L0.1606091410580.1353-100000@iolanthe.rowland.org>
 <50F437E3-85F7-4034-BAAE-B2558173A2EA@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <50F437E3-85F7-4034-BAAE-B2558173A2EA@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: iommu@lists.linux-foundation.org, Adam Morrison <mad@cs.technion.ac.il>, USB list <linux-usb@vger.kernel.org>, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>

Hello,

Am Donnerstag, den 09. Juni schrieb Nadav Amit:
> Alan Stern <stern@rowland.harvard.edu> wrote:
> 
> > On Thu, 9 Jun 2016, M G Berberich wrote:
> > 
> >> With 4.7-rc2, after detecting a USB Mass Storage device
> >> 
> >>  [   11.589843] usb-storage 4-2:1.0: USB Mass Storage device detected
> >> 
> >> a constant flow of kernel-BUGS is reported (several per second).

[a?|]

> > This looks like a bug in the memory management subsystem.  It should be 
> > reported on the linux-mm mailing list (CC'ed).
> 
> This bug is IOMMU related (mailing list CCa??ed) and IIUC already fixed.

Not fixed in 4.7-rc3

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
