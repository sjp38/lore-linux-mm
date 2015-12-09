Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF776B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:45:24 -0500 (EST)
Received: by wmww144 with SMTP id w144so230609670wmw.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:45:24 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id i204si5209605wmf.14.2015.12.09.08.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 08:45:23 -0800 (PST)
Received: by wmec201 with SMTP id c201so82197410wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:45:23 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <56684D3B.5050805@sr71.net>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011500.69487A6C@viggo.jf.intel.com>
 <5662894B.7090903@gmail.com> <5665B767.8020802@sr71.net> <56680BA6.20406@gmail.com>
 <56684D3B.5050805@sr71.net>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Wed, 9 Dec 2015 17:45:03 +0100
Message-ID: <CAKgNAkiZHny4amNcamN+q6pxdanG9aMMA4H_pekA7+RDuoUvEA@mail.gmail.com>
Subject: Re: [PATCH 26/34] mm: implement new mprotect_key() system call
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, dave.hansen@linux.intel.com, Linux API <linux-api@vger.kernel.org>

Hi Dave,

On 9 December 2015 at 16:48, Dave Hansen <dave@sr71.net> wrote:
> Hi Michael,
>
> Thanks for all the comments!  I'll fix most of it when I post a new
> version of the manpage, but I have a few general questions.
>
> On 12/09/2015 03:08 AM, Michael Kerrisk (man-pages) wrote:
>>>
>>> +is the protection or storage key to assign to the memory.
>>
>> Why "protection or storage key" here? This phrasing seems a
>> little ambiguous to me, given that we also have a 'prot'
>> argument.  I think it would be clearer just to say
>> "protection key". But maybe I'm missing something.
>
> x86 calls it a "protection key" while powerpc calls it a "storage key".
>  They're called "protection keys" consistently inside the kernel.
>
> Should we just stick to one name in the manpages?

Yes. But perhaps you could note the alternate name in the pkey(7) page.

>> * A general overview of why this functionality is useful.
>
> Any preference on a central spot to do the general overview?  Does it go
> in one of the manpages I'm already modifying, or a new one?

How about we add one more page, pkey(7) that gives the overview and
also summarizes the APIs.

>> * A note on which architectures support/will support
>>   this functionality.
>
> x86 only for now.  We might get powerpc support down the road somewhere.

Supported architectures can be listed in pkey(7).

>> * Explanation of what a protection domain is.
>
> A protection domain is a unique view of memory and is represented by the
> value in the PKRU register.

Out something about this in pkey(7), but explain what you mean by a
"unique view of memory".

>> * Explanation of how a process (thread?) changes its
>>   protection domain.
>
> Changing protection domains is done by pkey_set() system call, or by
> using the WRPKRU instruction.  The system call is preferred and less
> error-prone since it enforces that a protection is allocated before its
> access protection can be modified.

Details (perhaps not the WRPKRU bit) that should go in pkey(7).

>> * Explanation of the relationship between page permission
>>   bits (PROT_READ/PROT_WRITE/PROTE_EXEC) and
>>   PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE.
>>   It's still not clear to me. Do the PKEY_* bits
>>   override the PROT_* bits. Or, something else?
>
> Protection keys add access restrictions in addition to existing page
> permissions.  They can only take away access; they never grant
> additional access.

This belongs in pkey(7) :-).

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
