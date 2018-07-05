Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 338F96B027F
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 03:19:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so3683098wmh.0
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 00:19:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f203-v6sor1653883wmd.7.2018.07.05.00.19.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 00:19:40 -0700 (PDT)
Date: Thu, 5 Jul 2018 09:19:37 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 4.16 234/279] x86/pkeys/selftests: Adjust the self-test
 to fresh distros that export the pkeys ABI
Message-ID: <20180705071937.GA2636@gmail.com>
References: <20180618080608.851973560@linuxfoundation.org>
 <20180618080618.495174114@linuxfoundation.org>
 <fa4b973b-6037-eaef-3a63-09e8ca638527@suse.cz>
 <20180703114241.GA19730@kroah.com>
 <877emakynf.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877emakynf.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org, linuxram@us.ibm.com, shakeelb@google.com, shuah@kernel.org, Sasha Levin <alexander.levin@microsoft.com>


* Michael Ellerman <mpe@ellerman.id.au> wrote:

> Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:
> 
> > On Tue, Jul 03, 2018 at 01:36:43PM +0200, Vlastimil Babka wrote:
> >> On 06/18/2018 10:13 AM, Greg Kroah-Hartman wrote:
> >> > 4.16-stable review patch.  If anyone has any objections, please let me know.
> >> 
> >> So I was wondering, why backport such a considerable number of
> >> *selftests* to stable, given the stable policy? Surely selftests don't
> >> affect the kernel itself breaking for users?
> >
> > These came in as part of Sasha's "backport fixes" tool.  It can't hurt
> > to add selftest fixes/updates to stable kernels, as for some people,
> > they only run the selftests for the specific kernel they are building.
> > While others run selftests for the latest kernel on older kernels, both
> > of which are valid ways of testing.
> 
> I don't have a problem with these sort of patches being backported, but
> it seems like Documentation/process/stable-kernel-rules.txt could use an
> update?
> 
> I honestly don't know what the rules are anymore.

Self-tests are standalone tooling which help the testing of the kernel, and it 
makes sense to either update all of them, or none of them.

Here it makes sense to update all of them, because if a self-test on a stable 
kernel shows a failure then a fix is probably missing from -stable, right?

Also note that self-test tooling *cannot possibly break the kernel*, because they 
are not used in the kernel build process, so the normally conservative backporting 
rules do not apply.

Thanks,

	Ingo
