Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6686B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 06:37:51 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id gm9so39875447lab.0
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 03:37:50 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id la9si16754600lab.65.2015.02.02.03.37.48
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 03:37:49 -0800 (PST)
Date: Mon, 2 Feb 2015 13:37:40 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 17/19] x86: expose number of page table levels on
 Kconfig level
Message-ID: <20150202113740.GA11802@node.dhcp.inet.fi>
References: <1422629008-13689-18-git-send-email-kirill.shutemov@linux.intel.com>
 <1422664208-220779-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1422876393.19005.21.camel@x220>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422876393.19005.21.camel@x220>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Mon, Feb 02, 2015 at 12:26:33PM +0100, Paul Bolle wrote:
> On Sat, 2015-01-31 at 02:30 +0200, Kirill A. Shutemov wrote:
> > We would want to use number of page table level to define mm_struct.
> > Let's expose it as CONFIG_PGTABLE_LEVELS.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > ---
> >  v2: s/PAGETABLE_LEVELS/CONFIG_PGTABLE_LEVELS/ include/trace/events/xen.h
> 
> Isn't there some (informal) rule to update an entire series to a next
> version (and not only the patches that were changed in that version)?

It's up to maintainer. I can do any way. Last time I've asked, Andrew was
okay with v2 on individual patches.

> Anyhow, it seems you sent a v2 for 05/19, 11/19 and 17/19 only. Is that
> correct?

Correct. Plus one patch to fix build on all !MMU configurations.

I've also updated the git tree.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
