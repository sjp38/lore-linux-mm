Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id DAC916B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 17:39:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id f66so35537870lfe.23
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:39:16 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id c187si2476141lfc.70.2017.03.28.14.39.15
        for <linux-mm@kvack.org>;
        Tue, 28 Mar 2017 14:39:15 -0700 (PDT)
Date: Tue, 28 Mar 2017 23:38:59 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHv2 6/8] x86/dump_pagetables: Add support 5-level paging
Message-ID: <20170328213859.cltufwo5pdrhzna6@pd.tnic>
References: <20170328093946.GA30567@gmail.com>
 <20170328104806.41711-1-kirill.shutemov@linux.intel.com>
 <20170328185522.5akqgfh4niqi3ptf@pd.tnic>
 <20170328211507.ungejuigkewn6prl@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170328211507.ungejuigkewn6prl@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 29, 2017 at 12:15:07AM +0300, Kirill A. Shutemov wrote:
> On current tip/master?

tip/master from Monday:

commit d3b6ed97fbc63219e262faca86da2fe62885eff2 (refs/remotes/tip/master)
Merge: 399c980bd22b f2a6a7050109
Author: Ingo Molnar <mingo@kernel.org>
Date:   Mon Mar 27 10:48:30 2017 +0200

    Merge branch 'x86/mm'

> I'm not sure that collapsing history in one commit to fix bisectability is
> any better than having broken bisectability.

Of course it is better. How do you tell everyone who bisects in the
future to jump over those commits?

So perhaps not a single commit but at least meld those together which
change pagetable walking like the current example and cause a breakage.

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
