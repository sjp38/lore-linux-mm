Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 57E2D6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 00:20:24 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id 1so130207241ion.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 21:20:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l136si53824451iol.136.2016.01.04.21.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 21:20:23 -0800 (PST)
Date: Tue, 5 Jan 2016 13:20:03 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v2 14/16] x86, nvdimm, kexec: Use walk_iomem_res_desc()
 for iomem search
Message-ID: <20160105052003.GB3692@dhcp-128-65.nay.redhat.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
 <20151226103804.GB21988@pd.tnic>
 <567F315B.8080005@hpe.com>
 <20151227021257.GA13560@dhcp-128-25.nay.redhat.com>
 <20151227102406.GB19398@nazgul.tnic>
 <20160104092937.GB7033@dhcp-128-65.nay.redhat.com>
 <20160104122619.GH22941@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160104122619.GH22941@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Minfei Huang <mhuang@redhat.com>, Toshi Kani <toshi.kani@hpe.com>, linux-arch@vger.kernel.org, linux-nvdimm@ml01.01.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>

On 01/04/16 at 01:26pm, Borislav Petkov wrote:
> On Mon, Jan 04, 2016 at 05:29:37PM +0800, Dave Young wrote:
> > Replied to Toshi old kernel will export the "GART" region for amd cards.
> > So for old kernel and new kexec-tools we will have problem.
> > 
> > I think add the GART desc for compitibility purpose is doable, no?
> 
> Just read your other mails too. If I see it correctly, there's only one
> place which has "GART":
> 
> $ git grep -e \"GART\"
> arch/x86/kernel/crash.c:235:    walk_iomem_res("GART", IORESOURCE_MEM, 0, -1,
> 
> So crash.c only excludes this region but the kernel doesn't create it.
> Right?

Right.

> 
> So we can kill that walk_iomem_res(), as you say. Which would be even
> nicer...

Yes, I think it is ok to kill walk_iomem_res()

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
