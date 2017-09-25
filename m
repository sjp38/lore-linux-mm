Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B790C6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 09:16:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k20so9015172wre.6
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 06:16:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r12sor3201227edb.17.2017.09.25.06.16.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 06:16:14 -0700 (PDT)
Date: Mon, 25 Sep 2017 16:16:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv7 00/19] Boot-time switching between 4- and 5-level
 paging for 4.15
Message-ID: <20170925131612.eokduxczf5grrqte@node.shutemov.name>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 18, 2017 at 01:55:34PM +0300, Kirill A. Shutemov wrote:
> The basic idea is to implement the same logic as pgtable-nop4d.h provides,
> but at runtime.
> 
> Runtime folding is only implemented for CONFIG_X86_5LEVEL=y case. With the
> option disabled, we do compile-time folding as before.
> 
> Initially, I tried to fold pgd instread. I've got to shell, but it
> required a lot of hacks as kernel threats pgd in a special way.
> 
> Ingo, if no objections, could you apply the series?

Ingo, any chance you would find time for this?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
