Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7EC72802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 15:50:01 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v143so14769275qkb.6
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 12:50:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a36si8612817qkh.261.2017.06.30.12.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 12:50:00 -0700 (PDT)
Date: Fri, 30 Jun 2017 15:49:56 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 00/15] HMM (Heterogeneous Memory Management) v24
Message-ID: <20170630194956.GB4275@redhat.com>
References: <20170628180047.5386-1-jglisse@redhat.com>
 <960ef002-3cfd-5b91-054e-aa685abc5f1f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <960ef002-3cfd-5b91-054e-aa685abc5f1f@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>

On Thu, Jun 29, 2017 at 10:32:49PM -0700, John Hubbard wrote:
> On 06/28/2017 11:00 AM, Jerome Glisse wrote:
> > 
> > Patchset is on top of git://git.cmpxchg.org/linux-mmotm.git so i
> > test same kernel as kbuild system, git branch:
> > 
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v24
> > 
> > Change since v23 is code comment fixes, simplify kernel configuration and
> > improve allocation of new page on migration do device memory (last patch
> > in this patchset).
> 
> Hi Jerome,
> 
> Tiny note: one more change is that hmm_devmem_fault_range() has been
> removed (and thanks for taking care of that, btw).

True i forgot to mention that.

> 
> Anyway, this looks good. A basic smoke test shows the following:
> 
> 1. We definitely *require* your other patch, 
> "[PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove by not freeing pud v3",
> otherwise I will reliably hit that bug every time I run my simple page fault
> test. So, let me know if I should ping that thread. It looks like your patch
> was not rejected, but I can't tell if (!rejected == accepted), there. :)

Ingo did pick it up so it should shows in Linus tree soon i expect.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
