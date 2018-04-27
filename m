Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB2C46B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 12:28:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z20so1980302pfn.11
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 09:28:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 32-v6si1542294plc.252.2018.04.27.09.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 27 Apr 2018 09:28:24 -0700 (PDT)
Date: Fri, 27 Apr 2018 09:28:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180427162822.GE8161@bombadil.infradead.org>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180427053556.GB11339@infradead.org>
 <20180427161456.GD27853@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180427161456.GD27853@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, mhocko@kernel.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, Juergen Gross <jgross@suse.com>, linux-spi@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-scsi@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Fri, Apr 27, 2018 at 04:14:56PM +0000, Luis R. Rodriguez wrote:
> > Not really.  We have unchecked_isa_dma to support about 4 drivers,
> 
> Ah very neat:
> 
>   * CONFIG_CHR_DEV_OSST - "SCSI OnStream SC-x0 tape support"

That's an upper level driver, like cdrom, disk and regular tapes.

>   * CONFIG_SCSI_ADVANSYS - "AdvanSys SCSI support"

If we ditch support for the ISA boards, this can go away.

>   * CONFIG_SCSI_AHA1542 - "Adaptec AHA1542 support"

Probably true.

>   * CONFIG_SCSI_ESAS2R - "ATTO Technology's ExpressSAS RAID adapter driver"

That's being set to 0.

You missed BusLogic.c and gdth.c
