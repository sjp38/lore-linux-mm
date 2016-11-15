Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 021436B02AE
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 13:50:18 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so6194782wmf.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 10:50:17 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id pp3si29667002wjb.160.2016.11.15.10.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 10:50:16 -0800 (PST)
Date: Tue, 15 Nov 2016 19:50:15 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm: add ZONE_DEVICE statistics to smaps
Message-ID: <20161115185015.GA5854@lst.de>
References: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com> <CAPcyv4hTchhsNXhKx6WpUWsvFyZjzJ4sx1emLCSU2iDKSMG1hA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hTchhsNXhKx6WpUWsvFyZjzJ4sx1emLCSU2iDKSMG1hA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Dan,

On Mon, Nov 14, 2016 at 07:14:22PM -0800, Dan Williams wrote:
> Wanted to get your opinion on this given your earlier concerns about
> the VM_DAX flag.
> 
> This instead lets an application know how much of a vma is backed by
> ZONE_DEVICE pages, but does not make any indications about the vma
> having DAX semantics or not.  I.e. it is possible that 'device' and
> 'device_huge' are non-zero *and* vma_is_dax() is false.  So, it is
> purely accounting the composition of the present pages in the vma.
> 
> Another option is to have something like 'shared_thp' just to account
> for file backed huge pages that dax can map.  However if ZONE_DEVICE
> is leaking into other use cases I think it makes sense to have it be a
> first class-citizen with respect to accounting alongside
> 'anonymous_thp'.

This counter sounds fine to me, it's a debug tool and not an obvious
abuse candidate like VM_DAX.  But I'll defer to the VM folks for a real
review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
