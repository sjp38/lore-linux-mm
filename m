Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9AA6B025E
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 09:24:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l23so6904664pgc.10
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 06:24:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b25si8573970pgf.689.2017.10.19.06.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 06:24:31 -0700 (PDT)
Date: Thu, 19 Oct 2017 06:24:27 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Message-ID: <20171019132427.GA14440@bombadil.infradead.org>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <8760bci3vl.fsf@linux.intel.com>
 <20171019011056.GB17308@bombadil.infradead.org>
 <20171019043032.GY5109@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019043032.GY5109@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Srividya Desireddy <srividya.dr@samsung.com>, "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Wed, Oct 18, 2017 at 09:30:32PM -0700, Andi Kleen wrote:
> > Yes.  Every 64-bit repeating pattern is also a 32-bit repeating pattern.
> > Supporting a 64-bit pattern on a 32-bit kernel is painful, but it makes
> > no sense to *not* support a 64-bit pattern on a 64-bit kernel.  
> 
> But a 32bit repeating pattern is not necessarily a 64bit pattern.

Oops, I said it backwards.  What I mean is that if you have the repeating
pattern:

0x12345678 12345678 12345678 12345678 12345678 12345678

that's the same as the repeating pattern:

0x1234567812345678 1234567812345678 1234567812345678

so the 64-bit kernel is able to find all patterns that the 32-bit kernel is,
and more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
