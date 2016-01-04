Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0890F6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 14:46:25 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id ph11so765541igc.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 11:46:25 -0800 (PST)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id m81si29172438iom.134.2016.01.04.11.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 11:46:24 -0800 (PST)
Message-ID: <1451936749.19330.22.camel@hpe.com>
Subject: Re: [PATCH v2 14/16] x86, nvdimm, kexec: Use walk_iomem_res_desc()
 for iomem search
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 04 Jan 2016 12:45:49 -0700
In-Reply-To: <20160104194059.GM22941@pd.tnic>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
	 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
	 <20151226103804.GB21988@pd.tnic> <567F315B.8080005@hpe.com>
	 <20151227021257.GA13560@dhcp-128-25.nay.redhat.com>
	 <20151227102406.GB19398@nazgul.tnic>
	 <20160104092937.GB7033@dhcp-128-65.nay.redhat.com>
	 <20160104122619.GH22941@pd.tnic> <1451930260.19330.21.camel@hpe.com>
	 <20160104194059.GM22941@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Dave Young <dyoung@redhat.com>, Minfei Huang <mhuang@redhat.com>, linux-arch@vger.kernel.org, linux-nvdimm@ml01.01.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>

On Mon, 2016-01-04 at 20:41 +0100, Borislav Petkov wrote:
> On Mon, Jan 04, 2016 at 10:57:40AM -0700, Toshi Kani wrote:
> > With this change, there will be no caller to walk_iomem_res().  Should 
> > we remove walk_iomem_res() altogether, or keep it for now as a 
> > deprecated func with the checkpatch check?
> 
> Yes, kill it on the spot so that people don't get crazy ideas.

Will do.  

Thanks!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
