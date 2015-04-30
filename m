Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f45.google.com (mail-vn0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 22E046B0038
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 15:20:57 -0400 (EDT)
Received: by vnbf62 with SMTP id f62so8461940vnb.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 12:20:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h3si5431820vdc.35.2015.04.30.12.20.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Apr 2015 12:20:56 -0700 (PDT)
Date: Thu, 30 Apr 2015 21:20:45 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: slub: bulk allocation from per cpu partial pages
Message-ID: <20150430212045.1a8439d3@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1504301340150.28784@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org>
	<20150408155304.4480f11f16b60f09879c350d@linux-foundation.org>
	<alpine.DEB.2.11.1504090859560.19278@gentwo.org>
	<alpine.DEB.2.11.1504091215330.18198@gentwo.org>
	<20150416140638.684838a2@redhat.com>
	<alpine.DEB.2.11.1504161049030.8605@gentwo.org>
	<20150417074446.6dd16121@redhat.com>
	<20150417080610.4ae80965@redhat.com>
	<alpine.DEB.2.11.1504301340150.28784@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, brouer@redhat.com

On Thu, 30 Apr 2015 13:40:58 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Fri, 17 Apr 2015, Jesper Dangaard Brouer wrote:
> 
> > > Ups, I can see that this kernel don't have CONFIG_SLUB_CPU_PARTIAL,
> > > I'll re-run tests with this enabled.
> >
> > Results with CONFIG_SLUB_CPU_PARTIAL.
> >
> >  size    --  optimized -- fallback
> >  bulk  8 --  16ns      -- 22ns
> >  bulk 16 --  16ns      -- 22ns
> >  bulk 30 --  16ns      -- 22ns
> >  bulk 32 --  16ns      -- 22ns
> >  bulk 64 --  30ns      -- 38ns
> 
> That looks better. Can I get the code for testing? Then I can vary the
> approach a bit before posting patches? I still want to add a fast path for
> allocation from the per node partial list.

Sure you can get the code.  For now the test is fairly simple, will
expand later. I have made a branch "mm_bulk_api" to avoid
people using my repo getting compile errors (due to API not merged).

Git repo[1] branch "mm_bulk_api":
 [1] https://github.com/netoptimizer/prototype-kernel/

The test kernel module is called "slab_bulk_test01", located under
kernel/mm/slab_bulk_test01.c [2].


[2] https://github.com/netoptimizer/prototype-kernel/blob/mm_bulk_api/kernel/mm/slab_bulk_test01.c
Howto use repo [3]:
[3] http://netoptimizer.blogspot.dk/2014/11/announce-github-repo-prototype-kernel.html

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
