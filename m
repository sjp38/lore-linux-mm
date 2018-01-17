Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6E3280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:48:09 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id e69so10820108iod.17
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:48:09 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m139si3524176itb.88.2018.01.16.18.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 18:48:08 -0800 (PST)
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-3-git-send-email-joro@8bytes.org>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <476d7100-2414-d09e-abf1-5aa4d369a3b7@oracle.com>
Date: Tue, 16 Jan 2018 21:47:06 -0500
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-3-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de



On 01/16/2018 11:36 AM, Joerg Roedel wrote:

>   
>   /*
> + * Switch from the entry-trampline stack to the kernel stack of the
> + * running task.
> + *
> + * nr_regs is the number of dwords to push from the entry stack to the
> + * task stack. If it is > 0 it expects an irq frame at the bottom of the
> + * stack.
> + *
> + * check_user != 0 it will add a check to only switch stacks if the
> + * kernel entry was from user-space.
> + */
> +.macro SWITCH_TO_KERNEL_STACK nr_regs=0 check_user=0


This (and next patch's SWITCH_TO_ENTRY_STACK) need X86_FEATURE_PTI check.

With those macros fixed I was able to boot 32-bit Xen PV guest.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
