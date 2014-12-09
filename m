Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id BB4E16B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 14:27:54 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so1150177pde.12
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 11:27:54 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id cu3si3273770pbc.108.2014.12.09.11.27.52
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 11:27:53 -0800 (PST)
Date: Tue, 9 Dec 2014 11:27:51 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [next:master 10653/11539] arch/x86/ia32/audit.c:38:14: sparse:
 incompatible types for 'case' statement
Message-ID: <20141209192751.GA13752@wfg-t540p.sh.intel.com>
References: <201412090206.Nd6JUQcF%fengguang.wu@intel.com>
 <20141208130344.9dc58fda1862a4a4a14c7c6b@linux-foundation.org>
 <CAHse=S-7g77Dv+j7mUXgmAACs4czLQSv0VA361t=hecwQr03rg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHse=S-7g77Dv+j7mUXgmAACs4czLQSv0VA361t=hecwQr03rg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Drysdale <drysdale@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Dec 09, 2014 at 09:02:02AM +0000, David Drysdale wrote:
> On Mon, Dec 8, 2014 at 9:03 PM, Andrew Morton <akpm@linux-foundation.org>
> wrote:
> 
> > On Tue, 9 Dec 2014 02:40:09 +0800 kbuild test robot <
> > fengguang.wu@intel.com> wrote:
> >
> > > tree:   git://
> > git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > > head:   cf12164be498180dc466ef97194ca7755ea39f3b
> > > commit: b4baa9e36be0651f7eb15077af5e0eff53b7691b [10653/11539] x86: hook
> > up execveat system call
> > > reproduce:
> > >   # apt-get install sparse
> > >   git checkout b4baa9e36be0651f7eb15077af5e0eff53b7691b
> > >   make ARCH=x86_64 allmodconfig
> > >   make C=1 CF=-D__CHECK_ENDIAN__
> > >
> > >
> > > sparse warnings: (new ones prefixed by >>)
> > >
> > >    arch/x86/ia32/audit.c:38:14: sparse: undefined identifier
> > '__NR_execveat'
> > > >> arch/x86/ia32/audit.c:38:14: sparse: incompatible types for 'case'
> > statement
> > >    arch/x86/ia32/audit.c:38:14: sparse: Expected constant expression in
> > case statement
> > >    arch/x86/ia32/audit.c: In function 'ia32_classify_syscall':
> > >    arch/x86/ia32/audit.c:38:7: error: '__NR_execveat' undeclared (first
> > use in this function)
> > >      case __NR_execveat:
> > >           ^
> > >    arch/x86/ia32/audit.c:38:7: note: each undeclared identifier is
> > reported only once for each function it appears in
> > > --
> >
> > Confused. This makes no sense and I can't reproduce it.
> >
> 
> Ditto.

Sorry I cannot reproduce the issue, too. I've tried upgrading sparse.

> Someone else did previously[1] have a build problem from a stale copy of
> arch/x86/include/generated/asm/unistd_32.h in their tree, but I don't know
> how that could happen.
> 
> [1] https://lkml.org/lkml/2014/11/25/542

Since I'm doing incremental builds, it could happen that some left
over generated files lead to interesting errors.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
