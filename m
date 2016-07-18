Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D1CBA6B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:43:51 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k16so185958935qke.3
        for <linux-mm@kvack.org>; Sun, 17 Jul 2016 21:43:51 -0700 (PDT)
Received: from mail-vk0-x234.google.com (mail-vk0-x234.google.com. [2607:f8b0:400c:c05::234])
        by mx.google.com with ESMTPS id 21si1236205vkm.114.2016.07.17.21.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jul 2016 21:43:51 -0700 (PDT)
Received: by mail-vk0-x234.google.com with SMTP id x130so224173586vkc.0
        for <linux-mm@kvack.org>; Sun, 17 Jul 2016 21:43:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160714080701.GA14613@gmail.com>
References: <20160708071810.GA27457@gmail.com> <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com> <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
 <5783AE8F.3@sr71.net> <CALCETrW1qLZE_cq1CvmLkdnFyKRWVZuah29xERTC7o0eZ8DbwQ@mail.gmail.com>
 <5783BFB0.70203@intel.com> <CALCETrUZeZ00sFrTEqWSB-OxkCzGQxknmPTvFe4bv5mKc3hE+Q@mail.gmail.com>
 <20160713075550.GA515@gmail.com> <CALCETrUxL2ZAn8-GDtpwQPhLeNRXXp7RM1EVX2JExE+gkWGj3g@mail.gmail.com>
 <20160714080701.GA14613@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 17 Jul 2016 21:43:31 -0700
Message-ID: <CALCETrWPM_jrF6saHPxoUL4vkjhhGBfizATXrFOW=+z5xycToQ@mail.gmail.com>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, X86 ML <x86@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>

On Thu, Jul 14, 2016 at 1:07 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Andy Lutomirski <luto@amacapital.net> wrote:
>
>> On Wed, Jul 13, 2016 at 12:56 AM, Ingo Molnar <mingo@kernel.org> wrote:
>> >
>> > * Andy Lutomirski <luto@amacapital.net> wrote:
>> >
>> >> > If we push a PKRU value into a thread between the rdpkru() and wrpkru(), we'll
>> >> > lose the content of that "push".  I'm not sure there's any way to guarantee
>> >> > this with a user-controlled register.
>> >>
>> >> We could try to insist that user code uses some vsyscall helper that tracks
>> >> which bits are as-yet-unassigned.  That's quite messy, though.
>> >
>> > Actually, if we turned the vDSO into something more like a minimal user-space
>> > library with the ability to run at process startup as well to prepare stuff
>> > then it's painful to get right only *once*, and there will be tons of other
>> > areas where a proper per thread data storage on the user-space side would be
>> > immensely useful!
>>
>> Doing this could be tricky: how exactly is the vDSO supposed to find per-thread
>> data without breaking existing glibc?
>
> So I think the way this could be done is by allocating it itself. The vDSO vma
> itself is 'external' to glibc as well to begin with - this would be a small
> extension to that concept.

But how does the vdso code find it?  FS and GS are both spoken for by
existing userspace.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
