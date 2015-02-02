Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 419E16B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 06:57:39 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id k48so38544111wev.9
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 03:57:38 -0800 (PST)
Received: from cpsmtpb-ews09.kpnxchange.com (cpsmtpb-ews09.kpnxchange.com. [213.75.39.14])
        by mx.google.com with ESMTP id gh5si22910470wib.102.2015.02.02.03.57.37
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 03:57:37 -0800 (PST)
Message-ID: <1422878256.19005.22.camel@x220>
Subject: Re: [PATCHv2 17/19] x86: expose number of page table levels on
 Kconfig level
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 02 Feb 2015 12:57:36 +0100
In-Reply-To: <20150202113740.GA11802@node.dhcp.inet.fi>
References: 
	<1422629008-13689-18-git-send-email-kirill.shutemov@linux.intel.com>
	 <1422664208-220779-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1422876393.19005.21.camel@x220> <20150202113740.GA11802@node.dhcp.inet.fi>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>

On Mon, 2015-02-02 at 13:37 +0200, Kirill A. Shutemov wrote:
> On Mon, Feb 02, 2015 at 12:26:33PM +0100, Paul Bolle wrote:
> > Isn't there some (informal) rule to update an entire series to a next
> > version (and not only the patches that were changed in that version)?
> 
> It's up to maintainer. I can do any way. Last time I've asked, Andrew was
> okay with v2 on individual patches.
> 
> > Anyhow, it seems you sent a v2 for 05/19, 11/19 and 17/19 only. Is that
> > correct?
> 
> Correct. Plus one patch to fix build on all !MMU configurations.
> 
> I've also updated the git tree.

Which tree would that be?

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
