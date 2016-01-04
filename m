Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E8C246B0006
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 04:29:53 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so102306008pab.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 01:29:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id kh7si30772047pab.85.2016.01.04.01.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 01:29:53 -0800 (PST)
Date: Mon, 4 Jan 2016 17:29:37 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v2 14/16] x86, nvdimm, kexec: Use walk_iomem_res_desc()
 for iomem search
Message-ID: <20160104092937.GB7033@dhcp-128-65.nay.redhat.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
 <20151226103804.GB21988@pd.tnic>
 <567F315B.8080005@hpe.com>
 <20151227021257.GA13560@dhcp-128-25.nay.redhat.com>
 <20151227102406.GB19398@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151227102406.GB19398@nazgul.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Minfei Huang <mhuang@redhat.com>, Toshi Kani <toshi.kani@hpe.com>, linux-arch@vger.kernel.org, linux-nvdimm@ml01.01.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>

Hi, Boris

On 12/27/15 at 11:24am, Borislav Petkov wrote:
> On Sun, Dec 27, 2015 at 10:12:57AM +0800, Minfei Huang wrote:
> > You can refer the below link that you may get a clue about GART. This is
> > the fisrt time kexec-tools tried to support to ignore GART region in 2nd
> > kernel.
> > 
> > http://lists.infradead.org/pipermail/kexec/2008-December/003096.html
> 
> So theoretically we could export that IORES_DESC* enum in an uapi header and
> move kexec-tools to use that.
> 
> However, I'm fuzzy on how exactly the whole compatibility thing is done
> with kexec-tools and the kernel. We probably would have to support
> newer kexec-tools on an older kernel and vice versa so I'd guess we
> should mark walk_iomem_res() deprecated so that people are encouraged to
> upgrade to newer kexec-tools...

Replied to Toshi old kernel will export the "GART" region for amd cards.
So for old kernel and new kexec-tools we will have problem.

I think add the GART desc for compitibility purpose is doable, no?

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
