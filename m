Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 185FB6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 15:21:37 -0500 (EST)
Received: by wgha1 with SMTP id a1so6030658wgh.5
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 12:21:36 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id g4si31080867wie.103.2015.02.25.12.21.35
        for <linux-mm@kvack.org>;
        Wed, 25 Feb 2015 12:21:35 -0800 (PST)
Date: Wed, 25 Feb 2015 22:21:30 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: 4.0-rc1/PARISC: BUG: non-zero nr_pmds on freeing mm
Message-ID: <20150225202130.GA31491@node.dhcp.inet.fi>
References: <20150224225454.GA14117@fuloong-minipc.musicnaut.iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224225454.GA14117@fuloong-minipc.musicnaut.iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 25, 2015 at 12:54:54AM +0200, Aaro Koskinen wrote:
> Hi,
> 
> Here's a kernel config to reproduce the issue (no special steps needed,
> just boot to userspace), and bootlog after that:
> 
> #
> # Automatically generated file; DO NOT EDIT.
> # Linux/parisc 4.0.0-rc1 Kernel Configuration
...
> [   18.940000] BUG: non-zero nr_pmds on freeing mm: -6

It happens due missing __PAGETABLE_PMD_FOLDED in custom page table
folding. This has been fixed in CONFIG_PGTABLE_LEVELS patcheset.

Andrew, are you going to submit that patchset to Linus in this cycle?
If not, I can prepare a patchset which only adds missing
__PAGETABLE_PUD_FOLDED and __PAGETABLE_PMD_FOLDED.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
