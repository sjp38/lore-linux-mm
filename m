Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2E26B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:21:30 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b6so12641451pff.18
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:21:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i69sor16820pgc.225.2017.11.06.17.21.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 17:21:29 -0800 (PST)
Date: Tue, 7 Nov 2017 12:21:16 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH for 4.15 10/14] cpu_opv: Wire up powerpc system call
Message-ID: <20171107122116.7a75c3a8@roar.ozlabs.ibm.com>
In-Reply-To: <337041894.6072.1510015637355.JavaMail.zimbra@efficios.com>
References: <20171106092228.31098-1-mhocko@kernel.org>
	<1509992067.4140.1.camel@oracle.com>
	<20171106205644.29386-11-mathieu.desnoyers@efficios.com>
	<20171107113729.13369a30@roar.ozlabs.ibm.com>
	<337041894.6072.1510015637355.JavaMail.zimbra@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Boqun Feng <boqun.feng@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Dave Watson <davejwatson@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, 7 Nov 2017 00:47:17 +0000 (UTC)
Mathieu Desnoyers <mathieu.desnoyers@efficios.com> wrote:

> ----- On Nov 6, 2017, at 7:37 PM, Nicholas Piggin npiggin@gmail.com wrote:
> 
> > On Mon,  6 Nov 2017 15:56:40 -0500
> > Mathieu Desnoyers <mathieu.desnoyers@efficios.com> wrote:
> >   
> >> diff --git a/arch/powerpc/include/uapi/asm/unistd.h
> >> b/arch/powerpc/include/uapi/asm/unistd.h
> >> index b1980fcd56d5..972a7d68c143 100644
> >> --- a/arch/powerpc/include/uapi/asm/unistd.h
> >> +++ b/arch/powerpc/include/uapi/asm/unistd.h
> >> @@ -396,5 +396,6 @@
> >>  #define __NR_kexec_file_load	382
> >>  #define __NR_statx		383
> >>  #define __NR_rseq		384
> >> +#define __NR_cpu_opv		385  
> > 
> > Sorry for bike shedding, but could we invest a few more keystrokes to
> > make these names a bit more readable?  
> 
> Whenever I try to make variables or function names more explicit, I can
> literally feel my consciousness (taking the form of an angry Peter Zijlstra)
> breathing down my neck asking me to make them shorter. So I guess this is
> where it becomes a question of taste.

Specialist syscall is a bit different than a common function or variable
though.

> 
> I think the "rseq" syscall name is short, to the point, and should be mostly
> fine.

I'm not sure if it's really "to the point". I think kexec_file_load
is better than kfload, for example :)

> For "cpu_opv", it was just a short name that fit the bill until a
> better idea would come.
> 
> I'm open to suggestions. Any color preference ? ;-)

What can you do within 16 characters?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
