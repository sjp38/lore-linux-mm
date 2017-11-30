Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F70B6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:14:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d4so4055079pgv.4
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 02:14:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e89si2886359plb.731.2017.11.30.02.14.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 02:14:07 -0800 (PST)
Date: Thu, 30 Nov 2017 11:14:02 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
Message-ID: <20171130101402.ccgxsjqq66ty6ejk@pd.tnic>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
 <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
 <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
 <alpine.DEB.2.20.1711291740050.1825@nanos>
 <20171129170831.2iqpop2u534mgrbc@node.shutemov.name>
 <20171129174851.jk2ai37uumxve6sg@pd.tnic>
 <20171130073130.afualycggltkvl6s@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171130073130.afualycggltkvl6s@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 30, 2017 at 10:31:31AM +0300, Kirill A. Shutemov wrote:
> On Wed, Nov 29, 2017 at 05:48:51PM +0000, Borislav Petkov wrote:
> > On Wed, Nov 29, 2017 at 08:08:31PM +0300, Kirill A. Shutemov wrote:
> > > We're really early in the boot -- startup_64 in decompression code -- and
> > > I don't know a way print a message there. Is there a way?
> > > 
> > > no_longmode handled by just hanging the machine. Is it enough for no_la57
> > > case too?
> > 
> > Patch pls.
> 
> The patch below on top of patch 2/4 from this patch would do the trick.
> 
> Please give it a shot.

Yap, that works. Thanks!

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
