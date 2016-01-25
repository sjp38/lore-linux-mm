Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BA6D26B0009
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 16:35:22 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so381436pfd.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:35:22 -0800 (PST)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id fg8si36097219pad.227.2016.01.25.13.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 13:35:22 -0800 (PST)
Message-ID: <1453757661.834.99.camel@hpe.com>
Subject: Re: [PATCH v3 00/17] Enhance iomem search interfaces and support
 EINJ to NVDIMM
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 25 Jan 2016 14:34:21 -0700
In-Reply-To: <20160125191804.GE14030@pd.tnic>
References: <1452020068-26492-1-git-send-email-toshi.kani@hpe.com>
	 <20160125191804.GE14030@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, rafael.j.wysocki@intel.com, dan.j.williams@intel.com, dyoung@redhat.com, x86@kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, kexec@lists.infradead.org, xen-devel@lists.xenproject.org, linux-samsung-soc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 2016-01-25 at 20:18 +0100, Borislav Petkov wrote:
> On Tue, Jan 05, 2016 at 11:54:28AM -0700, Toshi Kani wrote:
> > This patch-set enhances the iomem table and its search interfacs, and
> > then changes EINJ to support NVDIMM.
> > 
 :
> 
> Ok, all applied ontop of 4.5-rc1.
> 
> You could take a look if everything's still fine and I haven't botched
> anything:
> 
> http://git.kernel.org/cgit/linux/kernel/git/bp/bp.git/log/?h=tip-mm

I verified the patches and tested the kernel in the tree.  All look good.

> I'll let the build bot chew on it and then test it here and send it out
> again to everyone on CC so that people don't act surprised.

Sounds great.

> Thanks for this cleanup, code looks much better now!

Thanks!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
