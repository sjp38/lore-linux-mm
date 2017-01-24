Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 43DEB6B026D
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:24:46 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 203so147362957ith.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:24:46 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 20si12903378itb.28.2017.01.24.13.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 13:24:45 -0800 (PST)
Date: Tue, 24 Jan 2017 16:24:35 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/3] 1G transparent hugepage support for device dax
Message-ID: <20170124212435.GA23874@char.us.oracle.com>
References: <148521477073.31533.17781371321988910714.stgit@djiang5-desk3.ch.intel.com>
 <20170124111248.GC20153@quack2.suse.cz>
 <CAPcyv4gW7cho=eE4BQZQ69J7ehREurP6CPbQX3z6eW7BUVT3Bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gW7cho=eE4BQZQ69J7ehREurP6CPbQX3z6eW7BUVT3Bw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Jan 24, 2017 at 10:26:54AM -0800, Dan Williams wrote:
> On Tue, Jan 24, 2017 at 3:12 AM, Jan Kara <jack@suse.cz> wrote:
> > On Mon 23-01-17 16:47:18, Dave Jiang wrote:
> >> The following series implements support for 1G trasparent hugepage on
> >> x86 for device dax. The bulk of the code was written by Mathew Wilcox
> >> a while back supporting transparent 1G hugepage for fs DAX. I have
> >> forward ported the relevant bits to 4.10-rc. The current submission has
> >> only the necessary code to support device DAX.
> >
> > Well, you should really explain why do we want this functionality... Is
> > anybody going to use it? Why would he want to and what will he gain by
> > doing so? Because so far I haven't heard of a convincing usecase.
> >
> 
> So the motivation and intended user of this functionality mirrors the
> motivation and users of 1GB page support in hugetlbfs. Given expected
> capacities of persistent memory devices an in-memory database may want
> to reduce tlb pressure beyond what they can already achieve with 2MB
> mappings of a device-dax file. We have customer feedback to that
> effect as Willy mentioned in his previous version of these patches
> [1].

CCing Nilesh who may be able to shed some more light on this.

> 
> [1]: https://lkml.org/lkml/2016/1/31/52
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
