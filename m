Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E63BB6B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 11:17:13 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bh1-v6so5799106plb.15
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 08:17:13 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b9-v6si1846638pfi.99.2018.10.03.08.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 08:17:13 -0700 (PDT)
Message-ID: <c4d78905d1914fc1d15c919fabff6f83756e4ab4.camel@intel.com>
Subject: Re: [RFC PATCH v4 18/27] x86/cet/shstk: User-mode shadow stack
 support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 03 Oct 2018 08:12:29 -0700
In-Reply-To: <20181003150754.GC32759@asgard.redhat.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-19-yu-cheng.yu@intel.com>
	 <20181003150754.GC32759@asgard.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugene Syromiatnikov <esyr@redhat.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-10-03 at 17:08 +0200, Eugene Syromiatnikov wrote:
> On Fri, Sep 21, 2018 at 08:03:42AM -0700, Yu-cheng Yu wrote:
> 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 5ea1d64cb0b4..b20450dde5b7 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -652,6 +652,9 @@ static void show_smap_vma_flags(struct seq_file *m,
> > struct vm_area_struct *vma)
> >  		[ilog2(VM_PKEY_BIT4)]	= "",
> >  #endif
> >  #endif /* CONFIG_ARCH_HAS_PKEYS */
> > +#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
> > +		[ilog2(VM_SHSTK)]	= "ss"
> > +#endif
> 
> It's probably makes sense to have this hunk as a part of "x86/cet/shstk:
> Add Kconfig option for user-mode shadow stack", where VM_SHSTK was
> initially introduced.

Yes, move it to "mm/Introduce VM_SHSTK for shadow stack memory".

Yu-cheng
