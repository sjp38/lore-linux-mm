Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 815DA6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 21:00:16 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l64so98632457oif.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 18:00:16 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id x79si3879266oix.34.2016.09.09.18.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 18:00:15 -0700 (PDT)
Received: by mail-oi0-x22c.google.com with SMTP id m11so176980206oif.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 18:00:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <147318057109.30325.17721163157375660986.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147318057109.30325.17721163157375660986.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 9 Sep 2016 18:00:14 -0700
Message-ID: <CAPcyv4jqsPuOMMbkjUtNSxd+vJXaoyJXvX_ttGfS12bCyRDtfg@mail.gmail.com>
Subject: Re: [PATCH 2/5] dax: fix offset to physical address translation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Tue, Sep 6, 2016 at 9:49 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> In pgoff_to_phys() 'pgoff' is already relative to base of the dax
> device, so we only need to compare if the current offset is within the
> current resource extent.  Otherwise, we are double accounting the
> resource start offset when translating pgoff to a physical address.
>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

On second look this results in the exact same translation, correct in
both cases.  This is also confirmed by a new ndctl unit test that does
data verification by writing through a /dev/pmem device and the
verifying via a /dev/dax device associated with the same namespace, so
I'm dropping this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
