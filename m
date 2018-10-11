Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D7E926B0008
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 16:53:48 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s15-v6so7568763pgv.9
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 13:53:48 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id c22-v6si25628256pgb.472.2018.10.11.13.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 13:53:47 -0700 (PDT)
Message-ID: <c61b4c393f938ee6e97f84d97ed76867ae75cb02.camel@intel.com>
Subject: Re: [PATCH v5 07/27] mm/mmap: Create a guard area between VMAs
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 11 Oct 2018 13:49:00 -0700
In-Reply-To: <CAG48ez3R7XL8MX_sjff1FFYuARX_58wA_=ACbv2im-XJKR8tvA@mail.gmail.com>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
	 <20181011151523.27101-8-yu-cheng.yu@intel.com>
	 <CAG48ez3R7XL8MX_sjff1FFYuARX_58wA_=ACbv2im-XJKR8tvA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, Andy Lutomirski <luto@amacapital.net>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, rdunlap@infradead.org, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com, Daniel Micay <danielmicay@gmail.com>

On Thu, 2018-10-11 at 22:39 +0200, Jann Horn wrote:
> On Thu, Oct 11, 2018 at 5:20 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > Create a guard area between VMAs to detect memory corruption.
> 
> [...]
> > +config VM_AREA_GUARD
> > +       bool "VM area guard"
> > +       default n
> > +       help
> > +         Create a guard area between VM areas so that access beyond
> > +         limit can be detected.
> > +
> >  endmenu
> 
> Sorry to bring this up so late, but Daniel Micay pointed out to me
> that, given that VMA guards will raise the number of VMAs by
> inhibiting vma_merge(), people are more likely to run into
> /proc/sys/vm/max_map_count (which limits the number of VMAs to ~65k by
> default, and can't easily be raised without risking an overflow of
> page->_mapcount on systems with over ~800GiB of RAM, see
> https://lore.kernel.org/lkml/20180208021112.GB14918@bombadil.infradead.org/
> and replies) with this change.

Can we use the VMA guard only for Shadow Stacks?

Yu-cheng
