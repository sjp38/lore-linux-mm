Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 50C5B6B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 15:10:05 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id u56so29131576wes.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 12:10:04 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id ee1si22709993wjd.89.2015.01.30.12.09.59
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 12:10:03 -0800 (PST)
Date: Fri, 30 Jan 2015 22:09:56 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/19] expose page table levels on Kconfig leve
Message-ID: <20150130200956.GB30401@node.dhcp.inet.fi>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150130172613.GA12367@roeck-us.net>
 <20150130185052.GA30401@node.dhcp.inet.fi>
 <20150130191435.GA16823@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130191435.GA16823@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 30, 2015 at 11:14:35AM -0800, Guenter Roeck wrote:
> On Fri, Jan 30, 2015 at 08:50:52PM +0200, Kirill A. Shutemov wrote:
> > On Fri, Jan 30, 2015 at 09:26:13AM -0800, Guenter Roeck wrote:
> > > On Fri, Jan 30, 2015 at 04:43:09PM +0200, Kirill A. Shutemov wrote:
> > > > I've failed my attempt on split up mm_struct into separate header file to
> > > > be able to use defines from <asm/pgtable.h> to define mm_struct: it causes
> > > > too much breakage and requires massive de-inlining of some architectures
> > > > (notably ARM and S390 with PGSTE).
> > > > 
> > > > This is other approach: expose number of page table levels on Kconfig
> > > > level and use it to get rid of nr_pmds in mm_struct.
> > > > 
> > > Hi Kirill,
> > > 
> > > Can I pull this series from somewhere ?
> > 
> > Just pushed:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git config_pgtable_levels
> > 
> 
> Great. Pushed into my 'testing' branch. I'll let you know how it goes.

0-DAY kernel testing has already reported few issues on blackfin, ia64 and
x86 with xen.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
