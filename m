Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3256B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 15:30:50 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so7344725pdb.11
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 12:30:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id im8si3607634pbc.229.2015.02.25.12.30.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 12:30:49 -0800 (PST)
Date: Wed, 25 Feb 2015 12:30:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 4.0-rc1/PARISC: BUG: non-zero nr_pmds on freeing mm
Message-Id: <20150225123048.a9c97ea726f747e029b4688a@linux-foundation.org>
In-Reply-To: <20150225202130.GA31491@node.dhcp.inet.fi>
References: <20150224225454.GA14117@fuloong-minipc.musicnaut.iki.fi>
	<20150225202130.GA31491@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Feb 2015 22:21:30 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Wed, Feb 25, 2015 at 12:54:54AM +0200, Aaro Koskinen wrote:
> > Hi,
> > 
> > Here's a kernel config to reproduce the issue (no special steps needed,
> > just boot to userspace), and bootlog after that:
> > 
> > #
> > # Automatically generated file; DO NOT EDIT.
> > # Linux/parisc 4.0.0-rc1 Kernel Configuration
> ...
> > [   18.940000] BUG: non-zero nr_pmds on freeing mm: -6
> 
> It happens due missing __PAGETABLE_PMD_FOLDED in custom page table
> folding. This has been fixed in CONFIG_PGTABLE_LEVELS patcheset.
> 
> Andrew, are you going to submit that patchset to Linus in this cycle?

I wasn't planning on doing so - the changelog didn't say anything about
fixing any regressions.

> If not, I can prepare a patchset which only adds missing
> __PAGETABLE_PUD_FOLDED and __PAGETABLE_PMD_FOLDED.

Something simple would be preferred, but I don't know how much simpler
the above would be?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
