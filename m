Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBE526B0287
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 23:16:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d10-v6so4126214pgv.8
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 20:16:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h10-v6sor3196157pfc.126.2018.06.16.20.16.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Jun 2018 20:16:15 -0700 (PDT)
Message-ID: <2b77abb17dfaf58b7c23fac9d8603482e1887337.camel@gmail.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
From: Balbir Singh <bsingharora@gmail.com>
Date: Sun, 17 Jun 2018 13:16:02 +1000
In-Reply-To: <1528988176.13101.15.camel@2b52.sc.intel.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <bbfde1b3-5e1b-80e3-30e8-fd1e46a2ceb1@gmail.com>
	 <1528815820.8271.16.camel@2b52.sc.intel.com>
	 <814fc15e80908d8630ff665be690ccbe6e69be88.camel@gmail.com>
	 <1528988176.13101.15.camel@2b52.sc.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, 2018-06-14 at 07:56 -0700, Yu-cheng Yu wrote:
> On Thu, 2018-06-14 at 11:07 +1000, Balbir Singh wrote:
> > On Tue, 2018-06-12 at 08:03 -0700, Yu-cheng Yu wrote:
> > > On Tue, 2018-06-12 at 20:56 +1000, Balbir Singh wrote:
> > > > 
> > > > On 08/06/18 00:37, Yu-cheng Yu wrote:
> > > > > This series introduces CET - Shadow stack
> > > > > 
> > > > > At the high level, shadow stack is:
> > > > > 
> > > > > 	Allocated from a task's address space with vm_flags VM_SHSTK;
> > > > > 	Its PTEs must be read-only and dirty;
> > > > > 	Fixed sized, but the default size can be changed by sys admin.
> > > > > 
> > > > > For a forked child, the shadow stack is duplicated when the next
> > > > > shadow stack access takes place.
> > > > > 
> > > > > For a pthread child, a new shadow stack is allocated.
> > > > > 
> > > > > The signal handler uses the same shadow stack as the main program.
> > > > > 
> > > > 
> > > > Even with sigaltstack()?
> > > > 
> > > 
> > > Yes.
> > 
> > I am not convinced that it would work, as we switch stacks, oveflow might
> > be an issue. I also forgot to bring up setcontext(2), I presume those
> > will get new shadow stacks
> 
> Do you mean signal stack/sigaltstack overflow or swapcontext in a signal
> handler?
>

I meant any combination of that. If there is a user space threads implementation that uses sigaltstack for switching threads

Balbir Singh.
 
> Yu-cheng
> 
