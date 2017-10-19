Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8652A6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:30:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l24so5705232pgu.17
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:30:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g6si6778077pgq.135.2017.10.18.21.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 21:30:33 -0700 (PDT)
Date: Wed, 18 Oct 2017 21:30:32 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Message-ID: <20171019043032.GY5109@tassilo.jf.intel.com>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <8760bci3vl.fsf@linux.intel.com>
 <20171019011056.GB17308@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019011056.GB17308@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Srividya Desireddy <srividya.dr@samsung.com>, "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

> Yes.  Every 64-bit repeating pattern is also a 32-bit repeating pattern.
> Supporting a 64-bit pattern on a 32-bit kernel is painful, but it makes
> no sense to *not* support a 64-bit pattern on a 64-bit kernel.  

But a 32bit repeating pattern is not necessarily a 64bit pattern.

>This is the same approach used in zram, fwiw.

Sounds bogus.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
