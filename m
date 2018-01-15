Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C645F6B0069
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 03:51:46 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v18so7966940wrf.21
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 00:51:46 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u5si5191014wmb.105.2018.01.15.00.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jan 2018 00:51:45 -0800 (PST)
Date: Mon, 15 Jan 2018 09:51:44 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: revamp vmem_altmap / dev_pagemap handling V3
Message-ID: <20180115085144.GA32532@lst.de>
References: <20171229075406.1936-1-hch@lst.de> <20180108112646.GA7204@lst.de> <CAPcyv4hHipDHP5LZCgym5szqiUSCxG9wQUbRO_qe8T+USaZi9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hHipDHP5LZCgym5szqiUSCxG9wQUbRO_qe8T+USaZi9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nvdimm@lists.01.org, X86 ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Mon, Jan 08, 2018 at 11:44:02AM -0800, Dan Williams wrote:
> On Mon, Jan 8, 2018 at 3:26 AM, Christoph Hellwig <hch@lst.de> wrote:
> > Any chance to get this fully reviewed and picked up before the
> > end of the merge window?
> 
> I'm fine carrying these through the nvdimm tree, but I'd need an ack
> from the mm folks for all the code touches related to arch_add_memory.

Looks like we got some semi ACKs, so I'd really like to see this go
in now as we have both nvdimm and p2p patches depending on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
