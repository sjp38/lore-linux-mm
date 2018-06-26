Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 652526B0006
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 11:00:07 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id a4-v6so5495346pls.16
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 08:00:07 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a8-v6si1455702pgu.544.2018.06.26.08.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 08:00:05 -0700 (PDT)
Message-ID: <1530024994.27091.0.camel@intel.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 26 Jun 2018 07:56:34 -0700
In-Reply-To: <CAG48ez2puLWrDDPg=ighCY+yxFoP-nN97MqVseqYabBad+eKmg@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <CAG48ez2puLWrDDPg=ighCY+yxFoP-nN97MqVseqYabBad+eKmg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hjl.tools@gmail.com, vedvyas.shanbhogue@intel.com, ravi.v.shankar@intel.com, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue, 2018-06-26 at 04:46 +0200, Jann Horn wrote:
> On Tue, Jun 26, 2018 at 4:45 AM Yu-cheng Yu <yu-cheng.yu@intel.com>
> wrote:
> > 
> > 
> > This series introduces CET - Shadow stack
> > 
> > At the high level, shadow stack is:
> > 
> > A A A A A A A A Allocated from a task's address space with vm_flags
> > VM_SHSTK;
> > A A A A A A A A Its PTEs must be read-only and dirty;
> > A A A A A A A A Fixed sized, but the default size can be changed by sys
> > admin.
> > 
> > For a forked child, the shadow stack is duplicated when the next
> > shadow stack access takes place.
> > 
> > For a pthread child, a new shadow stack is allocated.
> > 
> > The signal handler uses the same shadow stack as the main program.
> > 
> > Yu-cheng Yu (10):
> > A  x86/cet: User-mode shadow stack support
> > A  x86/cet: Introduce WRUSS instruction
> > A  x86/cet: Signal handling for shadow stack
> > A  x86/cet: Handle thread shadow stack
> > A  x86/cet: ELF header parsing of Control Flow Enforcement
> > A  x86/cet: Add arch_prctl functions for shadow stack
> > A  mm: Prevent mprotect from changing shadow stack
> > A  mm: Prevent mremap of shadow stack
> > A  mm: Prevent madvise from changing shadow stack
> > A  mm: Prevent munmap and remap_file_pages of shadow stack
> Shouldn't patches like these be CC'ed to linux-api@vger.kernel.org?

Yes, I will do that.

Thanks,
Yu-cheng
