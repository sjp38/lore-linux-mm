Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 186BE6B0263
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 14:44:09 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so181528945pac.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 11:44:08 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id td8si12112871pab.154.2015.09.28.11.44.07
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 11:44:08 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 01/15] avr32: convert to asm-generic/memory_model.h
Date: Mon, 28 Sep 2015 18:44:05 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B041E8@ORSMSX114.amr.corp.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044118.36490.75919.stgit@dwillia2-desk3.jf.intel.com>
 <20150924151002.GA24375@infradead.org>
 <CAPcyv4h_UrwTM7QiNMzxC3uV7bLOMKC4cNqwbikyj6w4AiKjWA@mail.gmail.com>
 <20150926201027.GB27728@infradead.org>
In-Reply-To: <20150926201027.GB27728@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, "Williams, Dan J" <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>

> Seems like we should simply introduce a CONFIG_VMEM_MAP for ia64
> to get this started.  Does my memory trick me or did we used to have
> vmem_map on other architectures as well but managed to get rid of it
> everywhere but on ia64?

I think ia64 hung onto this because of the SGI sn1 platforms. They were
even more discontiguous than even SPARSEMEM_EXTREME could handle

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
