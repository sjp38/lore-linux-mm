Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 331CF6B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 02:46:47 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id n5so12853391wmn.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:46:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10si6833806wjx.188.2016.01.26.23.46.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 23:46:46 -0800 (PST)
Date: Wed, 27 Jan 2016 07:46:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
Message-ID: <20160127074640.GG3104@suse.de>
References: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160126141152.e1043d14502dcca17813afb3@linux-foundation.org>
 <CAPcyv4hytzxpNt2RT6b5M6iuqz6V3GdSnO3eHwqpHVt4gfXPxg@mail.gmail.com>
 <20160126145153.44e4f38b04200209d133c0a3@linux-foundation.org>
 <CAPcyv4im4yQqLqRW9DsNRVsRTgWH1CPu1diJryZ4T57rDCWrzg@mail.gmail.com>
 <20160127011817.GA7398@js1304-P5Q-DELUXE>
 <CAPcyv4i9-mdPCVdrODOWS19vKKJJYuMZrvXbZ9eZKZc3Ua3QRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAPcyv4i9-mdPCVdrODOWS19vKKJJYuMZrvXbZ9eZKZc3Ua3QRA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Tue, Jan 26, 2016 at 05:37:38PM -0800, Dan Williams wrote:
> >> Will do, especially since other efforts are feeling the pinch on the
> >> MAX_NR_ZONES limitation.
> >
> > Please refer my previous attempt to add a new zone, ZONE_CMA.
> >
> > https://lkml.org/lkml/2015/2/12/84
> >
> > It salvages a bit from SECTION_WIDTH by increasing section size.
> > Similarly, I guess we can reduce NODE_WIDTH if needed although
> > it could cause to reduce maximum node size.
> 
> Dave pointed out to me that LAST__PID_SHIFT might be a better
> candidate to reduce to 7 bits.  That field is for storing pids which
> are already bigger than 8 bits.  If it is relying on the fact that
> pids don't rollover very often then likely the impact of 7-bits
> instead of 8 will be minimal.

It's not relying on the fact pids don't roll over very often. The
information is used by automatic NUMA balancing to detect if multiple
accesses to data are from the same task or not. Reducing the number of
bits it uses increases the chance that two tasks will both think they are
the data owner and keep migrating it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
