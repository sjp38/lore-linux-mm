Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8DD6B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:16:20 -0500 (EST)
Received: by oihr132 with SMTP id r132so9320671oih.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:16:20 -0800 (PST)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id mi9si9733719obc.25.2015.12.11.12.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 12:16:19 -0800 (PST)
Received: by obc18 with SMTP id 18so90681870obc.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:16:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56622401.20001@sr71.net>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <CALCETrXwVb99hAvqR2o54aPwtpr8oubROtiRt45SiYRfUTAxCw@mail.gmail.com>
 <56622401.20001@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 11 Dec 2015 12:16:00 -0800
Message-ID: <CALCETrXxe0cWXz9TG__Ju8hFXg0X9gKfBjU_GvFK3DWTW6AL0w@mail.gmail.com>
Subject: Re: [PATCH 00/34] x86: Memory Protection Keys (v5)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Dec 4, 2015 at 3:38 PM, Dave Hansen <dave@sr71.net> wrote:
> On 12/04/2015 03:31 PM, Andy Lutomirski wrote:
>> On Thu, Dec 3, 2015 at 5:14 PM, Dave Hansen <dave@sr71.net> wrote:
>>> Memory Protection Keys for User pages is a CPU feature which will
>>> first appear on Skylake Servers, but will also be supported on
>>> future non-server parts.  It provides a mechanism for enforcing
>>> page-based protections, but without requiring modification of the
>>> page tables when an application changes protection domains.  See
>>> the Documentation/ patch for more details.
>>
>> What, if anything, happened to the signal handling parts?
>
> Patches 12 and 13 contain most of it:
>
>         x86, pkeys: fill in pkey field in siginfo
>         signals, pkeys: notify userspace about protection key faults
>
> I decided to just not try to preserve the pkey_get/set() semantics
> across entering and returning from signals, fwiw.

Hmm.  I'll see if I can find some time this weekend to play with that
bit.  Maybe I can test by faking it and tweaking MPX instead of PKRU.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
