Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7953E6B026B
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 12:35:01 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id f71so6721998oib.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 09:35:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d71si1098453oic.259.2018.01.16.09.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 09:35:00 -0800 (PST)
Subject: Re: [PATCH 06/16] x86/mm/ldt: Reserve high address-space range for
 the LDT
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-7-git-send-email-joro@8bytes.org>
 <20180116165213.GF2228@hirez.programming.kicks-ass.net>
 <20180116171343.GB28161@8bytes.org>
 <20180116173115.GG2228@hirez.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Message-ID: <13a45e59-5969-2fdb-25cd-adcd5298784b@redhat.com>
Date: Tue, 16 Jan 2018 12:34:36 -0500
MIME-Version: 1.0
In-Reply-To: <20180116173115.GG2228@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On 01/16/2018 12:31 PM, Peter Zijlstra wrote:
> On Tue, Jan 16, 2018 at 06:13:43PM +0100, Joerg Roedel wrote:
>> Hi Peter,
>>
>> On Tue, Jan 16, 2018 at 05:52:13PM +0100, Peter Zijlstra wrote:
>>> On Tue, Jan 16, 2018 at 05:36:49PM +0100, Joerg Roedel wrote:
>>>> From: Joerg Roedel <jroedel@suse.de>
>>>>
>>>> Reserve 2MB/4MB of address space for mapping the LDT to
>>>> user-space.
>>> LDT is 64k, we need 2 per CPU, and NR_CPUS <= 64 on 32bit, that gives
>>> 64K*2*64=8M > 2M.
>> Thanks, I'll fix that in the next version.
> Just lower the max SMP setting until it fits or something. 32bit is too
> address space starved for lots of CPU in any case, 64 CPUs on 32bit is
> absolutely insane.

Maybe we can just scale the amount of reserved space according to the
current NR_CPUS setting. In this way, we won't waste more memory than is
necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
