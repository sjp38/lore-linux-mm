Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id A60946B006C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 15:41:51 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id g201so36494659oib.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 12:41:51 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id d133si5798752oif.24.2015.01.30.12.41.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 12:41:50 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YHINz-003TxY-0i
	for linux-mm@kvack.org; Fri, 30 Jan 2015 20:41:51 +0000
Date: Fri, 30 Jan 2015 12:41:37 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 00/19] expose page table levels on Kconfig leve
Message-ID: <20150130204137.GA32470@roeck-us.net>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150130172613.GA12367@roeck-us.net>
 <20150130185052.GA30401@node.dhcp.inet.fi>
 <20150130191435.GA16823@roeck-us.net>
 <20150130200956.GB30401@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130200956.GB30401@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 30, 2015 at 10:09:56PM +0200, Kirill A. Shutemov wrote:
> On Fri, Jan 30, 2015 at 11:14:35AM -0800, Guenter Roeck wrote:
> > On Fri, Jan 30, 2015 at 08:50:52PM +0200, Kirill A. Shutemov wrote:
> > > On Fri, Jan 30, 2015 at 09:26:13AM -0800, Guenter Roeck wrote:
> > > > On Fri, Jan 30, 2015 at 04:43:09PM +0200, Kirill A. Shutemov wrote:
> > > > > I've failed my attempt on split up mm_struct into separate header file to
> > > > > be able to use defines from <asm/pgtable.h> to define mm_struct: it causes
> > > > > too much breakage and requires massive de-inlining of some architectures
> > > > > (notably ARM and S390 with PGSTE).
> > > > > 
> > > > > This is other approach: expose number of page table levels on Kconfig
> > > > > level and use it to get rid of nr_pmds in mm_struct.
> > > > > 
> > > > Hi Kirill,
> > > > 
> > > > Can I pull this series from somewhere ?
> > > 
> > > Just pushed:
> > > 
> > > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git config_pgtable_levels
> > > 
> > 
> > Great. Pushed into my 'testing' branch. I'll let you know how it goes.
> 
> 0-DAY kernel testing has already reported few issues on blackfin, ia64 and
> x86 with xen.
> 

My build is still going on, but I can already see additional failures on
http://server.roeck-us.net:8010/builders (c6x, m68k, microblaze, ppc).

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
