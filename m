Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A67A56B0256
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 17:09:11 -0500 (EST)
Received: by padhx2 with SMTP id hx2so52406687pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 14:09:11 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qj4si7261257pac.33.2015.12.02.14.09.10
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 14:09:10 -0800 (PST)
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
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
 <565F69FE.601@intel.com>
 <CAPcyv4i0n=2+WMACVumvMHsXZ7xzBuzvO6WA9H06N_-S=s3ibQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <565F6C06.9060208@intel.com>
Date: Wed, 2 Dec 2015 14:09:10 -0800
MIME-Version: 1.0
In-Reply-To: <CAPcyv4i0n=2+WMACVumvMHsXZ7xzBuzvO6WA9H06N_-S=s3ibQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/02/2015 02:03 PM, Dan Williams wrote:
>>> >> Is pfn_valid() a reliable check?  It seems to be based on a max_pfn
>>> >> per node... what happens when pmem is located below that point.  I
>>> >> haven't been able to convince myself that we won't get false
>>> >> positives, but maybe I'm missing something.
>> >
>> > With sparsemem at least, it makes sure that you're looking at a valid
>> > _section_.  See the pfn_valid() at ~include/linux/mmzone.h:1222.
> At a minimum we would need to add "depends on SPARSEMEM" to "config FS_DAX_PMD".

Yeah, it seems like an awful layering violation.  But, sparsemem is
turned on everywhere (all the distros/users) that we care about, as far
as I know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
