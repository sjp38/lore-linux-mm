Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B059F6B0006
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 10:59:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j10-v6so2211650pgv.6
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 07:59:29 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e189-v6si4555873pgc.461.2018.06.14.07.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 07:59:28 -0700 (PDT)
Message-ID: <1528988176.13101.15.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 14 Jun 2018 07:56:16 -0700
In-Reply-To: <814fc15e80908d8630ff665be690ccbe6e69be88.camel@gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <bbfde1b3-5e1b-80e3-30e8-fd1e46a2ceb1@gmail.com>
	 <1528815820.8271.16.camel@2b52.sc.intel.com>
	 <814fc15e80908d8630ff665be690ccbe6e69be88.camel@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, 2018-06-14 at 11:07 +1000, Balbir Singh wrote:
> On Tue, 2018-06-12 at 08:03 -0700, Yu-cheng Yu wrote:
> > On Tue, 2018-06-12 at 20:56 +1000, Balbir Singh wrote:
> > > 
> > > On 08/06/18 00:37, Yu-cheng Yu wrote:
> > > > This series introduces CET - Shadow stack
> > > > 
> > > > At the high level, shadow stack is:
> > > > 
> > > > 	Allocated from a task's address space with vm_flags VM_SHSTK;
> > > > 	Its PTEs must be read-only and dirty;
> > > > 	Fixed sized, but the default size can be changed by sys admin.
> > > > 
> > > > For a forked child, the shadow stack is duplicated when the next
> > > > shadow stack access takes place.
> > > > 
> > > > For a pthread child, a new shadow stack is allocated.
> > > > 
> > > > The signal handler uses the same shadow stack as the main program.
> > > > 
> > > 
> > > Even with sigaltstack()?
> > > 
> > Yes.
> 
> I am not convinced that it would work, as we switch stacks, oveflow might
> be an issue. I also forgot to bring up setcontext(2), I presume those
> will get new shadow stacks

Do you mean signal stack/sigaltstack overflow or swapcontext in a signal
handler?

Yu-cheng
