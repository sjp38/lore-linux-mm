Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC57228029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 09:08:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k126so4227797wmd.5
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 06:08:12 -0800 (PST)
Received: from SMTP.EU.CITRIX.COM (smtp.eu.citrix.com. [185.25.65.24])
        by mx.google.com with ESMTPS id j50si593599ede.121.2018.01.17.06.08.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 06:08:11 -0800 (PST)
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-3-git-send-email-joro@8bytes.org>
 <476d7100-2414-d09e-abf1-5aa4d369a3b7@oracle.com>
 <20180117090238.GH28161@8bytes.org>
From: Andrew Cooper <andrew.cooper3@citrix.com>
Message-ID: <97298add-9484-7d83-50a3-1c668ce3107d@citrix.com>
Date: Wed, 17 Jan 2018 14:04:22 +0000
MIME-Version: 1.0
In-Reply-To: <20180117090238.GH28161@8bytes.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H .
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On 17/01/18 09:02, Joerg Roedel wrote:
> Hi Boris,
>
> thanks for testing this :)
>
> On Tue, Jan 16, 2018 at 09:47:06PM -0500, Boris Ostrovsky wrote:
>> On 01/16/2018 11:36 AM, Joerg Roedel wrote:
>>> +.macro SWITCH_TO_KERNEL_STACK nr_regs=0 check_user=0
>>
>> This (and next patch's SWITCH_TO_ENTRY_STACK) need X86_FEATURE_PTI check.
>>
>> With those macros fixed I was able to boot 32-bit Xen PV guest.
> Hmm, on bare metal the stack switch happens regardless of the
> X86_FEATURE_PTI feature being set, because we always program tss.sp0
> with the systenter stack. How is the kernel entry stack setup on xen-pv?
> I think something is missing there instead.

There is one single stack registered with Xen, on which you get a normal
exception frame in all cases, even via the registered (virtual)
syscall/sysenter/failsafe handlers.

~Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
