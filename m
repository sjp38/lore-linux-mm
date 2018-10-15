Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFA9A6B000A
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 09:18:47 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j90-v6so16077934wrj.20
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 06:18:47 -0700 (PDT)
Received: from david.siemens.de (david.siemens.de. [192.35.17.14])
        by mx.google.com with ESMTPS id 133-v6si7398162wmd.194.2018.10.15.06.18.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 06:18:46 -0700 (PDT)
Subject: Re: [PATCH] x86/entry/32: Fix setup of CS high bits
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
 <1531906876-13451-11-git-send-email-joro@8bytes.org>
 <97421241-2bc4-c3f1-4128-95b3e8a230d1@siemens.com>
 <35a24feb-5970-aa03-acbf-53428a159ace@web.de>
 <CALCETrWveao7jthnfKr5F=UyEpyowP0VA20eZi5OxizgT05EDA@mail.gmail.com>
 <406a08c7-6199-a32d-d385-c032fb4c34d6@siemens.com>
 <a16919d7e6504ad59a0fad828690bcb9@AcuMS.aculab.com>
From: Jan Kiszka <jan.kiszka@siemens.com>
Message-ID: <1246b176-02bf-3c04-5470-69333951263b@siemens.com>
Date: Mon, 15 Oct 2018 15:18:12 +0200
MIME-Version: 1.0
In-Reply-To: <a16919d7e6504ad59a0fad828690bcb9@AcuMS.aculab.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>

On 15.10.18 15:14, David Laight wrote:
> From: Jan Kiszka
>> Sent: 15 October 2018 14:09
> ...
>>> Those fields are genuinely 16 bit.  So the comment should say
>>> something like "Those high bits are used for CS_FROM_ENTRY_STACK and
>>> CS_FROM_USER_CR3".
>>
>> /*
>>    * The high bits of the CS dword (__csh) are used for
>>    * CS_FROM_ENTRY_STACK and CS_FROM_USER_CR3. Clear them in case
>>    * hardware didn't do this for us.
>>    */
> 
> What's a 'dword' ? :-)
> 
> On a 32bit processor a 'word' will be 32 bits to a 'double-word'
> would be 64 bits.
> One of the worst names to use.

That's ia32 nomenclature: a doubleword (dword) is a 32-bit value.

Jan

-- 
Siemens AG, Corporate Technology, CT RDA IOT SES-DE
Corporate Competence Center Embedded Linux
