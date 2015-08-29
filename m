Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id BEB556B0038
	for <linux-mm@kvack.org>; Sat, 29 Aug 2015 09:57:16 -0400 (EDT)
Received: by wicfv10 with SMTP id fv10so27702000wic.1
        for <linux-mm@kvack.org>; Sat, 29 Aug 2015 06:57:16 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id ge8si11168074wic.115.2015.08.29.06.57.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Aug 2015 06:57:15 -0700 (PDT)
Date: Sat, 29 Aug 2015 15:57:14 +0200
From: "hch@lst.de" <hch@lst.de>
Subject: Re: [PATCH v2 5/9] x86, pmem: push fallback handling to arch code
Message-ID: <20150829135714.GC13103@lst.de>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com> <20150826012751.8851.78564.stgit@dwillia2-desk3.amr.corp.intel.com> <20150826124124.GA7613@lst.de> <1440624859.31365.17.camel@intel.com> <1440798084.14237.106.camel@hp.com> <CAPcyv4iaado-ARQ4z=4jCYH3n7x5+pNsbDjd9XkWyiu=aFyBWA@mail.gmail.com> <1440798506.14237.107.camel@hp.com> <1440821097.32027.2.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440821097.32027.2.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "toshi.kani@hp.com" <toshi.kani@hp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "hch@lst.de" <hch@lst.de>, "hpa@zytor.com" <hpa@zytor.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "mingo@redhat.com" <mingo@redhat.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "boaz@plexistor.com" <boaz@plexistor.com>, "david@fromorbit.com" <david@fromorbit.com>

On Sat, Aug 29, 2015 at 04:04:58AM +0000, Williams, Dan J wrote:
> On Fri, 2015-08-28 at 15:48 -0600, Toshi Kani wrote:
> > On Fri, 2015-08-28 at 14:47 -0700, Dan Williams wrote:
> > > On Fri, Aug 28, 2015 at 2:41 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > > > On Wed, 2015-08-26 at 21:34 +0000, Williams, Dan J wrote:
> > > [..]
> > > > > -#define ARCH_MEMREMAP_PMEM MEMREMAP_WB
> > > > 
> > > > Should it be better to do:
> > > > 
> > > > #else   /* !CONFIG_ARCH_HAS_PMEM_API */
> > > > #define ARCH_MEMREMAP_PMEM MEMREMAP_WT
> > > > 
> > > > so that you can remove all '#ifdef ARCH_MEMREMAP_PMEM' stuff?
> > > 
> > > Yeah, that seems like a nice incremental cleanup for memremap_pmem()
> > > to just unconditionally use ARCH_MEMREMAP_PMEM, feel free to send it
> > > along.
> > 
> > OK. Will do.
> > 
> 
> Here's the re-worked patch with Toshi's fixes folded in:

I like this in principle, but we'll have to be carefull now if we
want to drop the fallbacks in mremap, as we will have to shift it into
the pmem driver then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
