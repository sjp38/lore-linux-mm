Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C1B496B000A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:59:21 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g6-v6so4637148iti.7
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 06:59:21 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i32-v6si12901058jak.68.2018.07.12.06.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 06:59:20 -0700 (PDT)
Subject: Re: [PATCH 00/39 v7] PTI support for x86-32
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <CA+55aFzrG+GV5ySVUiiod8Va5P0_vmUuh25Pner1r7c_aQgH9g@mail.gmail.com>
 <nycvar.YFH.7.76.1807111923420.997@cbobk.fhfr.pm>
 <1225b274-534b-cc32-54eb-aba89efba494@mageia.org>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <dac081f7-d3f4-d81d-46e6-076f1e3f13a1@oracle.com>
Date: Thu, 12 Jul 2018 09:59:01 -0400
MIME-Version: 1.0
In-Reply-To: <1225b274-534b-cc32-54eb-aba89efba494@mageia.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Backlund <tmb@mageia.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>
Cc: Jiri Kosina <jikos@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 07/11/2018 03:57 PM, Thomas Backlund wrote:
> Den 2018-07-11 kl. 20:28, skrev Jiri Kosina:
>> On Wed, 11 Jul 2018, Linus Torvalds wrote:
>>
>>> It's the testing that worries me most. Pretty much no developers run
>>> 32-bit any more, and I'd be most worried about the odd interactions
>>> that
>>> might be hw-specific. Some crazy EFI mapping setup or the similar odd
>>> case that simply requires a particular configuration or setup.
>>>
>>> But I guess those issues will never be found until we just spring this
>>> all on the unsuspecting public.
>>
>> FWIW we shipped Joerg's 32bit KAISER kernel out to our 32bit users
>> (on old
>> product where we still support it) on Apr 25th already (and some issues
>> have been identified since then because of that). So it (or its port to
>> 3.0, to be more precise :p) already did receive some crowd-testing.
>>
>
> And Mageia has had v2 since February 13th patched into 4.14 -longterm,
> then updated to v3 at March 5th, and updated to v4 at March 19th and
> been running that since then (since v5 is rebased on v4.17 we stayed
> with v4)
>
>
> So, here is another "lets merge it upstream" vote :)


I had a quick boot test for Xen (PV and HVM) and they both looked OK. I
didn't boot all the way to login prompt but that's most likely due to
issues in my environment -- I haven't tried this image in a year or so
and my other setup is offline right now.

-boris
