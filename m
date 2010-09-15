Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A6CA66B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 10:46:51 -0400 (EDT)
Received: by yxk8 with SMTP id 8so125341yxk.14
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 07:46:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C90A6C7.9050607@redhat.com>
References: <20100915104855.41de3ebf@lilo> <4C90A6C7.9050607@redhat.com>
From: Bryan Donlan <bdonlan@gmail.com>
Date: Wed, 15 Sep 2010 23:46:09 +0900
Message-ID: <AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Christopher Yeoh <cyeoh@au1.ibm.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 19:58, Avi Kivity <avi@redhat.com> wrote:

> Instead of those two syscalls, how about a vmfd(pid_t pid, ulong start,
> ulong len) system call which returns an file descriptor that represents a
> portion of the process address space. =A0You can then use preadv() and
> pwritev() to copy memory, and io_submit(IO_CMD_PREADV) and
> io_submit(IO_CMD_PWRITEV) for asynchronous variants (especially useful wi=
th
> a dma engine, since that adds latency).
>
> With some care (and use of mmu_notifiers) you can even mmap() your vmfd a=
nd
> access remote process memory directly.

Rather than introducing a new vmfd() API for this, why not just add
implementations for these more efficient operations to the existing
/proc/$pid/mem interface?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
