Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0DF6B041F
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 12:59:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so32412257wrd.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:59:41 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id d4si9993092wrb.215.2017.06.21.09.59.39
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 09:59:39 -0700 (PDT)
Date: Wed, 21 Jun 2017 18:59:22 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 26/34] iommu/amd: Allow the AMD IOMMU to work with
 memory encryption
Message-ID: <20170621165921.tv2jfhf5dz7hsjsy@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191745.28645.81756.stgit@tlendack-t1.amdoffice.net>
 <20170614174208.p2yr5exs4b6pjxhf@pd.tnic>
 <0611d01a-19f8-d6ae-2682-932789855518@amd.com>
 <20170615094111.wga334kg2bhxqib3@pd.tnic>
 <20170621153721.GP30388@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170621153721.GP30388@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 21, 2017 at 05:37:22PM +0200, Joerg Roedel wrote:
> > Do you mean this is like the last exception case in that document above:
> > 
> > "
> >   - Pointers to data structures in coherent memory which might be modified
> >     by I/O devices can, sometimes, legitimately be volatile.  A ring buffer
> >     used by a network adapter, where that adapter changes pointers to
> >     indicate which descriptors have been processed, is an example of this
> >     type of situation."
> > 
> > ?
> 
> So currently (without this patch) the build_completion_wait function
> does not take a volatile parameter, only wait_on_sem() does.
> 
> Wait_on_sem() needs it because its purpose is to poll a memory location
> which is changed by the iommu-hardware when its done with command
> processing.

Right, the reason above - memory modifiable by an IO device. You could
add a comment there explaining the need for the volatile.

> But the 'volatile' in build_completion_wait() looks unnecessary, because
> the function does not poll the memory location. It only uses the
> pointer, converts it to a physical address and writes it to the command
> to be queued.

Ok.

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
