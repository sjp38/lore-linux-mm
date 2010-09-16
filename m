Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2900D6B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 21:18:35 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id o8G1FVAj000821
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 11:15:31 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8G1IRrF2293850
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 11:18:28 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8G1IRLj013565
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 11:18:27 +1000
Date: Thu, 16 Sep 2010 10:48:19 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100916104819.36d10acb@lilo>
In-Reply-To: <AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com>
References: <20100915104855.41de3ebf@lilo>
	<4C90A6C7.9050607@redhat.com>
	<AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Bryan Donlan <bdonlan@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010 23:46:09 +0900
Bryan Donlan <bdonlan@gmail.com> wrote:

> On Wed, Sep 15, 2010 at 19:58, Avi Kivity <avi@redhat.com> wrote:
>=20
> > Instead of those two syscalls, how about a vmfd(pid_t pid, ulong
> > start, ulong len) system call which returns an file descriptor that
> > represents a portion of the process address space. =A0You can then
> > use preadv() and pwritev() to copy memory, and
> > io_submit(IO_CMD_PREADV) and io_submit(IO_CMD_PWRITEV) for
> > asynchronous variants (especially useful with a dma engine, since
> > that adds latency).
> >
> > With some care (and use of mmu_notifiers) you can even mmap() your
> > vmfd and access remote process memory directly.
>=20
> Rather than introducing a new vmfd() API for this, why not just add
> implementations for these more efficient operations to the existing
> /proc/$pid/mem interface?

Perhaps I'm misunderstanding something here, but
accessing /proc/$pid/mem requires ptracing the target process.
We can't really have all these MPI processes ptraceing each other
just to send/receive a message....

Regards,

Chris
--=20
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
