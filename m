Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B80A6B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 13:52:40 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id p85so43024434lfg.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 10:52:40 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id h29si4693445ljb.137.2017.03.02.10.52.38
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 10:52:38 -0800 (PST)
Date: Thu, 2 Mar 2017 19:51:51 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 27/28] x86: Add support to encrypt the kernel
 in-place
Message-ID: <20170302185151.nllxa4hty3tukfkr@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154808.19244.475.stgit@tlendack-t1.amdoffice.net>
 <20170301173623.zcf35xgyrhmo25a7@pd.tnic>
 <cc72330f-ab5b-229f-2962-5d27490aba7d@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <cc72330f-ab5b-229f-2962-5d27490aba7d@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Mar 02, 2017 at 12:30:31PM -0600, Tom Lendacky wrote:
> The "* 2" here and above is that a PUD and a PMD is needed for both
> the encrypted and decrypted mappings. I'll add a comment to clarify
> that.

Ah, makes sense. Definitely needs a comment.

> Yup, I can do that here too (but need PGDIR_SIZE).

Right, I did test and wanted to write PGDIR_SIZE but then ... I guess
something distracted me :-)

> So next_page is the first free page within the workarea in which a
> pagetable entry (PGD, PUD or PMD) can be created when we are populating
> the new mappings or adding the workarea to the current mapping.  Any
> new pagetable structures that are created will use this value.

Ok, so I guess this needs an overview comment with maybe some ascii
showing how workarea, exec_size, full_size and all those other things
play together.

> Ok, I'll work on the comment.  Something along the line of:
>
> /*
>  * The encrypted mapping of the kernel will use identity mapped
>  * virtual addresses.  A different PGD index/entry must be used to
>  * get different pagetable entries for the decrypted mapping.
>  * Choose the next PGD index and convert it to a virtual address
>  * to be used as the base of the mapping.

Better.

> Except the workarea size includes both the encryption execution
> size and the pagetable structure size.  I'll work on this to try
> and clarify it better.

That's a useful piece of info, yap, the big picture could use some more
explanation.

> Most definitely.  I appreciate the feedback since I'm very close to
> the code and have an understanding of what I'm doing. I'd like to be
> sure that everyone can easily understand what is happening.

Nice!

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
