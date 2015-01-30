Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id C1BD76B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 13:50:58 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id k48so28793986wev.12
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 10:50:58 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id hd10si8829843wib.37.2015.01.30.10.50.56
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 10:50:57 -0800 (PST)
Date: Fri, 30 Jan 2015 20:50:52 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/19] expose page table levels on Kconfig leve
Message-ID: <20150130185052.GA30401@node.dhcp.inet.fi>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150130172613.GA12367@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130172613.GA12367@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 30, 2015 at 09:26:13AM -0800, Guenter Roeck wrote:
> On Fri, Jan 30, 2015 at 04:43:09PM +0200, Kirill A. Shutemov wrote:
> > I've failed my attempt on split up mm_struct into separate header file to
> > be able to use defines from <asm/pgtable.h> to define mm_struct: it causes
> > too much breakage and requires massive de-inlining of some architectures
> > (notably ARM and S390 with PGSTE).
> > 
> > This is other approach: expose number of page table levels on Kconfig
> > level and use it to get rid of nr_pmds in mm_struct.
> > 
> Hi Kirill,
> 
> Can I pull this series from somewhere ?

Just pushed:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git config_pgtable_levels

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
