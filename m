Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32EBB6B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 15:55:38 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id c37so12435313wra.5
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 12:55:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m48sor4910240edd.4.2018.02.26.12.55.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 12:55:36 -0800 (PST)
Date: Mon, 26 Feb 2018 23:55:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/5] x86/boot/compressed/64: Prepare trampoline memory
Message-ID: <20180226205527.6m6h55h6r2cgh5hq@node.shutemov.name>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
 <20180226193244.GH14140@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180226193244.GH14140@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 26, 2018 at 08:32:44PM +0100, Borislav Petkov wrote:
> On Mon, Feb 26, 2018 at 09:04:46PM +0300, Kirill A. Shutemov wrote:
> > Borislav, could you check which patch breaks boot for you (if any)?
> 
> What is that ontop? tip/master from today or?

I made it on top of tip/x86/mm, but tip/master should be fine too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
