Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8916B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 16:00:38 -0500 (EST)
Received: by oige206 with SMTP id e206so33431654oig.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 13:00:38 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id nx7si4813825oeb.96.2015.12.02.13.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 13:00:37 -0800 (PST)
Message-ID: <1449093339.9855.1.camel@hpe.com>
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
From: Toshi Kani <toshi.kani@hpe.com>
Date: Wed, 02 Dec 2015 14:55:39 -0700
In-Reply-To: <CAPcyv4jtVkptiFhiFP=2KXvDXs=Tw17pF=249sLj2fw-0vgsEg@mail.gmail.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
	 <CAPcyv4gY2SZZwiv9DtjRk4js3gS=vf4YLJvmsMJ196aps4ZHcQ@mail.gmail.com>
	 <1449022764.31589.24.camel@hpe.com>
	 <CAPcyv4hzjMkwx3AA+f5Y9zfp-egjO-b5+_EU7cGO5BGMQaiN_g@mail.gmail.com>
	 <1449078237.31589.30.camel@hpe.com>
	 <CAPcyv4ikJ73nzQTCOfnBRThkv=rZGPM76S7=6O3LSB4kQBeEpw@mail.gmail.com>
	 <CAPcyv4j1vA6eAtjsE=kGKeF1EqWWfR+NC7nUcRpfH_8MRqpM8Q@mail.gmail.com>
	 <1449084362.31589.37.camel@hpe.com>
	 <CAPcyv4jt7JmWCgcsd=p32M322sCyaar4Pj-k+F446XGZvzrO8A@mail.gmail.com>
	 <1449086521.31589.39.camel@hpe.com> <1449087125.31589.45.camel@hpe.com>
	 <CAPcyv4hvX_s3xN9UZ69v7npOhWVFehfGDPZG1MsDmKWBk4Gq1A@mail.gmail.com>
	 <1449092226.31589.50.camel@hpe.com>
	 <CAPcyv4jtVkptiFhiFP=2KXvDXs=Tw17pF=249sLj2fw-0vgsEg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 2015-12-02 at 12:54 -0800, Dan Williams wrote:
> On Wed, Dec 2, 2015 at 1:37 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > On Wed, 2015-12-02 at 11:57 -0800, Dan Williams wrote:
> [..]
> > > The whole point of __get_user_page_fast() is to avoid the overhead of
> > > taking the mm semaphore to access the vma.  _PAGE_SPECIAL simply tells
> > > __get_user_pages_fast that it needs to fallback to the
> > > __get_user_pages slow path.
> > 
> > I see.  Then, I think gup_huge_pmd() can simply return 0 when !pfn_valid(),
> > instead of VM_BUG_ON.
> 
> Is pfn_valid() a reliable check?  It seems to be based on a max_pfn
> per node... what happens when pmem is located below that point.  I
> haven't been able to convince myself that we won't get false
> positives, but maybe I'm missing something.

I believe we use the version of pfn_valid() in linux/mmzone.h.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
