Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3765C6B0006
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 02:03:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e3-v6so4206857pfn.13
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 23:03:09 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id e62-v6si5439844pfe.327.2018.07.04.23.03.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Jul 2018 23:03:07 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 4.16 234/279] x86/pkeys/selftests: Adjust the self-test to fresh distros that export the pkeys ABI
In-Reply-To: <20180703114241.GA19730@kroah.com>
References: <20180618080608.851973560@linuxfoundation.org> <20180618080618.495174114@linuxfoundation.org> <fa4b973b-6037-eaef-3a63-09e8ca638527@suse.cz> <20180703114241.GA19730@kroah.com>
Date: Thu, 05 Jul 2018 16:03:00 +1000
Message-ID: <877emakynf.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org, linuxram@us.ibm.com, shakeelb@google.com, shuah@kernel.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@microsoft.com>

Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:

> On Tue, Jul 03, 2018 at 01:36:43PM +0200, Vlastimil Babka wrote:
>> On 06/18/2018 10:13 AM, Greg Kroah-Hartman wrote:
>> > 4.16-stable review patch.  If anyone has any objections, please let me know.
>> 
>> So I was wondering, why backport such a considerable number of
>> *selftests* to stable, given the stable policy? Surely selftests don't
>> affect the kernel itself breaking for users?
>
> These came in as part of Sasha's "backport fixes" tool.  It can't hurt
> to add selftest fixes/updates to stable kernels, as for some people,
> they only run the selftests for the specific kernel they are building.
> While others run selftests for the latest kernel on older kernels, both
> of which are valid ways of testing.

I don't have a problem with these sort of patches being backported, but
it seems like Documentation/process/stable-kernel-rules.txt could use an
update?

I honestly don't know what the rules are anymore.

cheers
