Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 645EC6B025E
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 04:03:57 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f16so15265190ioe.1
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 01:03:57 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p190si2953505itp.69.2017.11.02.01.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 01:03:56 -0700 (PDT)
Date: Thu, 2 Nov 2017 09:03:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Message-ID: <20171102080345.x2zceqtrad35bmh3@hirez.programming.kicks-ass.net>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171101085424.cwvc4nrrdhvjc3su@gmail.com>
 <d7cb1705-5ef0-5f6e-b1cf-e3f28e998477@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d7cb1705-5ef0-5f6e-b1cf-e3f28e998477@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, borisBrian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@google.com>

On Wed, Nov 01, 2017 at 03:14:11PM -0700, Dave Hansen wrote:
> On 11/01/2017 01:54 AM, Ingo Molnar wrote:
> > Beyond the inevitable cavalcade of (solvable) problems that will pop up during 
> > review, one major item I'd like to see addressed is runtime configurability: it 
> > should be possible to switch between a CR3-flushing and a regular syscall and page 
> > table model on the admin level, without restarting the kernel and apps. Distros 
> > really, really don't want to double the number of kernel variants they have.
> > 
> > The 'Kaiser off' runtime switch doesn't have to be as efficient as 
> > CONFIG_KAISER=n, at least initialloy, but at minimum it should avoid the most 
> > expensive page table switching paths in the syscall entry codepaths.
> 
> Due to popular demand, I went and implemented this today.  It's not the
> prettiest code I ever wrote, but it's pretty small.
> 
> Just in case anyone wants to play with it, I threw a snapshot of it up here:
> 
> > https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/log/?h=kaiser-dynamic-414rc6-20171101
> 
> I ran some quick tests.  When CONFIG_KAISER=y, but "echo 0 >
> kaiser-enabled", the tests that I ran were within the noise vs. a
> vanilla kernel, and that's with *zero* optimization.

I resent you don't think the NMI is performance critical ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
