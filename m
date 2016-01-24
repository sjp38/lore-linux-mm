Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 038296B0009
	for <linux-mm@kvack.org>; Sun, 24 Jan 2016 04:41:33 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id b14so39123639wmb.1
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 01:41:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q134si16901021wmb.96.2016.01.24.01.41.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 24 Jan 2016 01:41:31 -0800 (PST)
Date: Sun, 24 Jan 2016 10:40:56 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [BUG] Devices breaking due to CONFIG_ZONE_DEVICE
Message-ID: <20160124094056.GA27266@pd.tnic>
References: <20160123044643.GA3709@sudip-pc>
 <CAPcyv4hiKGXWWqO09dchQ3U429zV=Hrbm5d=cMzHkRj6_EpJig@mail.gmail.com>
 <CAPcyv4ivKNb2=505ytkVMbmOd=49da1EsHoG=Di60XJyoQTs8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4ivKNb2=505ytkVMbmOd=49da1EsHoG=Di60XJyoQTs8g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Christoph Hellwig <hch@lst.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <j.glisse@gmail.com>, markk@clara.co.uk, Joerg Roedel <jroedel@suse.de>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

+ linux-mm

On Fri, Jan 22, 2016 at 10:15:17PM -0800, Dan Williams wrote:
> On Fri, Jan 22, 2016 at 9:47 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > On Fri, Jan 22, 2016 at 8:46 PM, Sudip Mukherjee
> > <sudipm.mukherjee@gmail.com> wrote:
> >> Hi All,
> >> Commit 033fbae988fc ("mm: ZONE_DEVICE for "device memory"") has
> >> introduced CONFIG_ZONE_DEVICE while sacrificing CONFIG_ZONE_DMA.
> >> Distributions like Ubuntu has started enabling CONFIG_ZONE_DEVICE and
> >> thus breaking parallel port. Please have a look at
> >> https://bugzilla.kernel.org/show_bug.cgi?id=110931 for the bug report.
> >>
> >> Apart from parallel port I can see some sound drivers will also break.
> >>
> >> Now what is the possible solution for this?
> >
> > The tradeoff here is enabling direct-I/O for persistent memory vs
> > support for legacy devices.
> >
> > One possible solution is to alias ZONE_DMA and ZONE_DEVICE.  At early
> > boot if pmem is detected disable these legacy devices, or the reverse
> > disable DMA to persistent memory if a legacy device is detected.  The
> > latter is a bit harder to do as I think we would want to make the
> > decision early during memory init before we would know if any parallel
> > ports or ISA sound cards are present.
> 
> ...another option that might be cleaner is to teach GFP_DMA to get
> memory from a different mechanism.  I.e. don't use the mm-zone
> infrastructure to organize that small 16MB pool of memory.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
