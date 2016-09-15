Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82A466B0253
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:26:17 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k12so35039080lfb.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 01:26:17 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id lg5si214527wjc.143.2016.09.15.01.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 01:26:16 -0700 (PDT)
Date: Thu, 15 Sep 2016 10:26:15 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 2/3] mm, dax: add VM_DAX flag for DAX VMAs
Message-ID: <20160915082615.GA9772@lst.de>
References: <147392246509.9873.17750323049785100997.stgit@dwillia2-desk3.amr.corp.intel.com> <147392247875.9873.4205533916442000884.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <147392247875.9873.4205533916442000884.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, david@fromorbit.com, linux-kernel@vger.kernel.org, npiggin@gmail.com, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, hch@lst.de

On Wed, Sep 14, 2016 at 11:54:38PM -0700, Dan Williams wrote:
> The DAX property, page cache bypass, of a VMA is only detectable via the
> vma_is_dax() helper to check the S_DAX inode flag.  However, this is
> only available internal to the kernel and is a property that userspace
> applications would like to interrogate.

They have absolutely no business knowing such an implementation detail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
