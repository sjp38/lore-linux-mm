Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 07BB86B0253
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 03:55:32 -0500 (EST)
Received: by wmww144 with SMTP id w144so190886824wmw.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:55:31 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id t19si18230504wme.67.2015.11.12.00.55.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 00:55:31 -0800 (PST)
Received: by wmec201 with SMTP id c201so81076591wme.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:55:30 -0800 (PST)
Date: Thu, 12 Nov 2015 09:55:27 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
Message-ID: <20151112085527.GB18963@gmail.com>
References: <20151110123429.GE19187@pd.tnic>
 <20151110135303.GA11246@node.shutemov.name>
 <20151110144648.GG19187@pd.tnic>
 <20151110150713.GA11956@node.shutemov.name>
 <20151110170447.GH19187@pd.tnic>
 <20151111095101.GA22512@pd.tnic>
 <20151112074854.GA5376@gmail.com>
 <20151112075758.GA20702@node.shutemov.name>
 <20151112080059.GA6835@gmail.com>
 <20151112084616.EABFE19B@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151112084616.EABFE19B@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Borislav Petkov <bp@alien8.de>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, boris.ostrovsky@oracle.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> > But, what problems do you expect with having a wider mask than its primary usage? 
> > If it's used for 32-bit values it will be truncated down safely. (But I have not 
> > tested it, so I might be missing some complication.)
> 
> Yeah, I basically worry about non realized side effect.

Such a worry is prudent, the best way would be to double check a disassembly of a 
before/after vmlinux and see in which functions they differ and why.

We might have similar bugs elsewhere - silently fixed by such a change.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
