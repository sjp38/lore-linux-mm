Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB366B0253
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:24:29 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id x125so30654147pfb.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:24:29 -0800 (PST)
Received: from bby1mta02.pmc-sierra.bc.ca (bby1mta02.pmc-sierra.com. [216.241.235.117])
        by mx.google.com with ESMTPS id 127si19449709pfa.4.2016.01.28.14.24.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 14:24:28 -0800 (PST)
From: Stephen Bates <Stephen.Bates@pmcs.com>
Subject: [LSF/MM ATTEND] blk-mq polling, nvme, pmem (for iomem) and
 non-block based SSDs.
Date: Thu, 28 Jan 2016 22:24:27 +0000
Message-ID: <36F6EBABA23FEF4391AF72944D228901EB6F1F59@BBYEXM01.pmc-sierra.internal>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>

Hi

I would like to attend LSF/MM 2016 to participate in discussions around the=
 optimization of the block layer and memory management for low latency NVM =
technologies. I'd be very interested in discussions pertaining to where we =
can take the work being done to add polling into the block layer and tying =
that into file-systems and applications. I would also be keen to discuss ho=
w we might extend the recent work to facilitate large persistent memory reg=
ions to IO memory (e.g. PCIe devices with large, persistent, memory regions=
).

I am also keen to discuss topics associated with non-block based hardware d=
evices including things like NVDIMM, OpenChannel SSDs and persistent memory=
 exposed on PCIe devices.

I spend quite a bit of time working on elements of the block layer (especia=
lly NVMe), the RDMA stack and (more recently) the NVDIMM/PMEM/DAX sections =
of the kernel.

Cheers

Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
