Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4222E6B0006
	for <linux-mm@kvack.org>; Sun,  8 Jul 2018 06:33:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z9-v6so9686059pfe.23
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 03:33:47 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id o10-v6si11017312pgp.153.2018.07.08.03.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 08 Jul 2018 03:33:45 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 4.16 234/279] x86/pkeys/selftests: Adjust the self-test to fresh distros that export the pkeys ABI
In-Reply-To: <20180705071937.GA2636@gmail.com>
References: <20180618080608.851973560@linuxfoundation.org> <20180618080618.495174114@linuxfoundation.org> <fa4b973b-6037-eaef-3a63-09e8ca638527@suse.cz> <20180703114241.GA19730@kroah.com> <877emakynf.fsf@concordia.ellerman.id.au> <20180705071937.GA2636@gmail.com>
Date: Sun, 08 Jul 2018 20:33:37 +1000
Message-ID: <87va9qj9tq.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org, linuxram@us.ibm.com, shakeelb@google.com, shuah@kernel.org, Sasha Levin <alexander.levin@microsoft.com>

Ingo Molnar <mingo@kernel.org> writes:
> * Michael Ellerman <mpe@ellerman.id.au> wrote:
>> Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:
>> > On Tue, Jul 03, 2018 at 01:36:43PM +0200, Vlastimil Babka wrote:
>> >> On 06/18/2018 10:13 AM, Greg Kroah-Hartman wrote:
>> >> > 4.16-stable review patch.  If anyone has any objections, please let me know.
>> >> 
>> >> So I was wondering, why backport such a considerable number of
>> >> *selftests* to stable, given the stable policy? Surely selftests don't
>> >> affect the kernel itself breaking for users?
>> >
>> > These came in as part of Sasha's "backport fixes" tool.  It can't hurt
>> > to add selftest fixes/updates to stable kernels, as for some people,
>> > they only run the selftests for the specific kernel they are building.
>> > While others run selftests for the latest kernel on older kernels, both
>> > of which are valid ways of testing.
>> 
>> I don't have a problem with these sort of patches being backported, but
>> it seems like Documentation/process/stable-kernel-rules.txt could use an
>> update?
>> 
>> I honestly don't know what the rules are anymore.
>
> Self-tests are standalone tooling which help the testing of the kernel, and it 
> makes sense to either update all of them, or none of them.

Yes I know what selftests are.

> Here it makes sense to update all of them, because if a self-test on a stable 
> kernel shows a failure then a fix is probably missing from -stable, right?

Usually, though it's not always that simple IME.

But sure, I don't have a problem with updating selftests, I said that before.

> Also note that self-test tooling *cannot possibly break the kernel*, because they 
> are not used in the kernel build process, so the normally conservative backporting 
> rules do not apply.

Right. So stable-kernel-rules.txt could use an update to mention that.


My comment was less about this actual patch and more about the new
reality of patches being backported to stable based on Sasha's tooling,
which seems to be much more liberal than anything we've done previously.

I don't generally have any objection to that process, though it possibly
could have been more widely announced. But, it would be good if
stable-kernel-rules.txt was updated to mention it.

I've had several people ask me "hey my patch got backported to stable
but I didn't ask for it - is that OK, what's going on?" etc.

I guess I should just send a patch to update it, but I don't really know
what it should say.

cheers
