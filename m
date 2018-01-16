Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1B7D6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 05:50:02 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id i6so10352443wre.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 02:50:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w7sor1316540edw.20.2018.01.16.02.50.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 02:50:01 -0800 (PST)
Date: Tue, 16 Jan 2018 13:49:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 0/4] x86: 5-level related changes into decompression
 code<Paste>
Message-ID: <20180116104956.fxpv52eaaubyyfek@node.shutemov.name>
References: <20171212135739.52714-1-kirill.shutemov@linux.intel.com>
 <20171218101045.arwbzmbxbhqgreeu@node.shutemov.name>
 <20180108161805.jrpmkcrwlr2rs4sy@gmail.com>
 <20180112083757.okwsvdhqaodt2d3u@node.shutemov.name>
 <20180112141037.ktd2ryzx3tfwhsfx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180112141037.ktd2ryzx3tfwhsfx@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 12, 2018 at 03:10:37PM +0100, Ingo Molnar wrote:
> > Is there any other regression do you have in mind?
> 
> No, that's the main one I was worried about.

The fix is upstream now. Is there anything else I need to do to get this
patchset applied?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
