Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3D86B0003
	for <linux-mm@kvack.org>; Sun,  8 Jul 2018 23:28:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u16-v6so10881869pfm.15
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 20:28:21 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id b80-v6si14895395pfm.230.2018.07.08.20.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 08 Jul 2018 20:28:19 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 4.16 234/279] x86/pkeys/selftests: Adjust the self-test to fresh distros that export the pkeys ABI
In-Reply-To: <20180708132519.GA29528@kroah.com>
References: <20180618080608.851973560@linuxfoundation.org> <20180618080618.495174114@linuxfoundation.org> <fa4b973b-6037-eaef-3a63-09e8ca638527@suse.cz> <20180703114241.GA19730@kroah.com> <877emakynf.fsf@concordia.ellerman.id.au> <20180705071937.GA2636@gmail.com> <87va9qj9tq.fsf@concordia.ellerman.id.au> <20180708132519.GA29528@kroah.com>
Date: Mon, 09 Jul 2018 13:28:09 +1000
Message-ID: <87a7r19jg6.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org, linuxram@us.ibm.com, shakeelb@google.com, shuah@kernel.org, Sasha Levin <alexander.levin@microsoft.com>

Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:
> On Sun, Jul 08, 2018 at 08:33:37PM +1000, Michael Ellerman wrote:
...
>> 
>> My comment was less about this actual patch and more about the new
>> reality of patches being backported to stable based on Sasha's tooling,
>> which seems to be much more liberal than anything we've done previously.
>> 
>> I don't generally have any objection to that process, though it possibly
>> could have been more widely announced. But, it would be good if
>> stable-kernel-rules.txt was updated to mention it.
>> 
>> I've had several people ask me "hey my patch got backported to stable
>> but I didn't ask for it - is that OK, what's going on?" etc.
>
> Why didn't those people just ask us?  To not do so is very strange, it's
> not like we are hard to find :)

It's not very strange, it's completely normal behaviour. People are
afraid of asking dumb questions in public, so they ask someone
privately.

And the general sentiment has been "I didn't think that patch met the
stable rules, but I'm happy for it to be backported".

>> I guess I should just send a patch to update it, but I don't really know
>> what it should say.
>
> I don't think it really needs any changes, as the selftests is just a
> corner case that is easily explained if anyone cares enough to actually
> ask :)

Yeah again I'm not really concerned about selftests, I should have
replied to a different patch to start this discussion. My bad.

cheers
