Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80F0E6B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 12:50:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v186so1835259pfb.8
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 09:50:53 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40096.outbound.protection.outlook.com. [40.107.4.96])
        by mx.google.com with ESMTPS id 126si1578858pfd.48.2018.02.28.09.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Feb 2018 09:50:51 -0800 (PST)
Date: Wed, 28 Feb 2018 09:50:36 -0800
From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [PATCH v5 0/4] vm: add a syscall to map a process memory into a
 pipe
Message-ID: <20180228175035.GA20686@outlook.office365.com>
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
 <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
 <20180227021818.GA31386@altlinux.org>
 <627ac4f8-a52d-0582-0c9e-e70ea667fa7e@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <627ac4f8-a52d-0582-0c9e-e70ea667fa7e@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, gdb@sourceware.org, devel@lists.open-mpi.org, rr-dev@mozilla.org, Arnd Bergmann <arnd@arndb.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>

On Wed, Feb 28, 2018 at 10:12:55AM +0300, Pavel Emelyanov wrote:
> On 02/27/2018 05:18 AM, Dmitry V. Levin wrote:
> > On Mon, Feb 26, 2018 at 12:02:25PM +0300, Pavel Emelyanov wrote:
> >> On 02/21/2018 03:44 AM, Andrew Morton wrote:
> >>> On Tue,  9 Jan 2018 08:30:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> >>>
> >>>> This patches introduces new process_vmsplice system call that combines
> >>>> functionality of process_vm_read and vmsplice.
> >>>
> >>> All seems fairly strightforward.  The big question is: do we know that
> >>> people will actually use this, and get sufficient value from it to
> >>> justify its addition?
> >>
> >> Yes, that's what bothers us a lot too :) I've tried to start with finding out if anyone 
> >> used the sys_read/write_process_vm() calls, but failed :( Does anybody know how popular
> >> these syscalls are?
> > 
> > Well, process_vm_readv itself is quite popular, it's used by debuggers nowadays,
> > see e.g.
> > $ strace -qq -esignal=none -eprocess_vm_readv strace -qq -o/dev/null cat /dev/null
> 
> I see. Well, yes, this use-case will not benefit much from remote splice. How about more
> interactive debug by, say, gdb? It may attach, then splice all the memory, then analyze
> the victim code/data w/o copying it to its address space?

Hmm, in this case, you probably will want to be able to map pipe pages
into memory.

> 
> -- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
