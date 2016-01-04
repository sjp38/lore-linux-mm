Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 25B9C6B0006
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 12:58:18 -0500 (EST)
Received: by mail-oi0-f53.google.com with SMTP id o124so259438751oia.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 09:58:18 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id ct2si25815723oec.4.2016.01.04.09.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 09:58:17 -0800 (PST)
Message-ID: <1451930260.19330.21.camel@hpe.com>
Subject: Re: [PATCH v2 14/16] x86, nvdimm, kexec: Use walk_iomem_res_desc()
 for iomem search
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 04 Jan 2016 10:57:40 -0700
In-Reply-To: <20160104122619.GH22941@pd.tnic>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
	 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
	 <20151226103804.GB21988@pd.tnic> <567F315B.8080005@hpe.com>
	 <20151227021257.GA13560@dhcp-128-25.nay.redhat.com>
	 <20151227102406.GB19398@nazgul.tnic>
	 <20160104092937.GB7033@dhcp-128-65.nay.redhat.com>
	 <20160104122619.GH22941@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Dave Young <dyoung@redhat.com>
Cc: Minfei Huang <mhuang@redhat.com>, linux-arch@vger.kernel.org, linux-nvdimm@ml01.01.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>

On Mon, 2016-01-04 at 13:26 +0100, Borislav Petkov wrote:
> On Mon, Jan 04, 2016 at 05:29:37PM +0800, Dave Young wrote:
> > Replied to Toshi old kernel will export the "GART" region for amd
> > cards.
> > So for old kernel and new kexec-tools we will have problem.
> > 
> > I think add the GART desc for compitibility purpose is doable, no?
> 
> Just read your other mails too. If I see it correctly, there's only one
> place which has "GART":
> 
> $ git grep -e \"GART\"
> arch/x86/kernel/crash.c:235:    walk_iomem_res("GART", IORESOURCE_MEM, 0,
> -1,
> 
> So crash.c only excludes this region but the kernel doesn't create it.
> Right?
> 
> So we can kill that walk_iomem_res(), as you say. Which would be even
> nicer...

Agreed.  As Dave suggested in the other thread, we can simply remove the
walk_iomem_res("GART",) call in crash.c.  

With this change, there will be no caller to walk_iomem_res().  Should we
remove walk_iomem_res() altogether, or keep it for now as a deprecated func
with the checkpatch check? 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
