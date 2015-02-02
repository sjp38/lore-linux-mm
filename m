Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF906B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 07:07:12 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id q1so40021688lam.2
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 04:07:11 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id m1si16817573lam.44.2015.02.02.04.07.09
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 04:07:10 -0800 (PST)
Date: Mon, 2 Feb 2015 14:07:05 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 17/19] x86: expose number of page table levels on
 Kconfig level
Message-ID: <20150202120705.GA12793@node.dhcp.inet.fi>
References: <1422629008-13689-18-git-send-email-kirill.shutemov@linux.intel.com>
 <1422664208-220779-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1422876393.19005.21.camel@x220>
 <20150202113740.GA11802@node.dhcp.inet.fi>
 <1422878256.19005.22.camel@x220>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422878256.19005.22.camel@x220>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Mon, Feb 02, 2015 at 12:57:36PM +0100, Paul Bolle wrote:
> On Mon, 2015-02-02 at 13:37 +0200, Kirill A. Shutemov wrote:
> > On Mon, Feb 02, 2015 at 12:26:33PM +0100, Paul Bolle wrote:
> > > Isn't there some (informal) rule to update an entire series to a next
> > > version (and not only the patches that were changed in that version)?
> > 
> > It's up to maintainer. I can do any way. Last time I've asked, Andrew was
> > okay with v2 on individual patches.
> > 
> > > Anyhow, it seems you sent a v2 for 05/19, 11/19 and 17/19 only. Is that
> > > correct?
> > 
> > Correct. Plus one patch to fix build on all !MMU configurations.
> > 
> > I've also updated the git tree.
> 
> Which tree would that be?

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git config_pgtable_levels

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
