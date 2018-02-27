Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 440E16B000E
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 04:33:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q2so6694903pgf.22
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 01:33:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si8278255pfk.292.2018.02.27.01.33.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Feb 2018 01:33:11 -0800 (PST)
Date: Tue, 27 Feb 2018 10:32:43 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH 0/5] x86/boot/compressed/64: Prepare trampoline memory
Message-ID: <20180227093243.GA26382@pd.tnic>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
 <20180226193244.GH14140@pd.tnic>
 <20180226205527.6m6h55h6r2cgh5hq@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180226205527.6m6h55h6r2cgh5hq@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 26, 2018 at 11:55:27PM +0300, Kirill A. Shutemov wrote:
> On Mon, Feb 26, 2018 at 08:32:44PM +0100, Borislav Petkov wrote:
> > On Mon, Feb 26, 2018 at 09:04:46PM +0300, Kirill A. Shutemov wrote:
> > > Borislav, could you check which patch breaks boot for you (if any)?
> > 
> > What is that ontop? tip/master from today or?
> 
> I made it on top of tip/x86/mm, but tip/master should be fine too.

Ok, those 5 look good ontop of tip/master from last night.

I did a clean build and guest boot with each one applied in succession
just to make sure there's no funky business from the build system.

Tested-by: Borislav Petkov <bp@suse.de>

Thx.

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
