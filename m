Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CE2926B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 21:58:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G1wA9N015827
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Sep 2010 10:58:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF04945DE56
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:58:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3B2645DE50
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:58:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EEF6E08009
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:58:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A1EF1DB803E
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:58:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
In-Reply-To: <AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com>
References: <4C90A6C7.9050607@redhat.com> <AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com>
Message-Id: <20100916105311.CA00.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 16 Sep 2010 10:58:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Bryan Donlan <bdonlan@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Avi Kivity <avi@redhat.com>, Christopher Yeoh <cyeoh@au1.ibm.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> On Wed, Sep 15, 2010 at 19:58, Avi Kivity <avi@redhat.com> wrote:
>=20
> > Instead of those two syscalls, how about a vmfd(pid_t pid, ulong start,
> > ulong len) system call which returns an file descriptor that represents=
 a
> > portion of the process address space. =A0You can then use preadv() and
> > pwritev() to copy memory, and io_submit(IO_CMD_PREADV) and
> > io_submit(IO_CMD_PWRITEV) for asynchronous variants (especially useful =
with
> > a dma engine, since that adds latency).
> >
> > With some care (and use of mmu_notifiers) you can even mmap() your vmfd=
 and
> > access remote process memory directly.
>=20
> Rather than introducing a new vmfd() API for this, why not just add
> implementations for these more efficient operations to the existing
> /proc/$pid/mem interface?

As far as I heared from my friend, old HP MPI implementation used /proc/$pi=
d/mem
for this purpose. (I don't know current status). However almost implementat=
ion
doesn't do that because /proc/$pid/mem required the process is ptraced.
As far as I understand , very old /proc/$pid/mem doesn't require it. but It=
 changed
for security concern. Then, Anybody haven't want to change this interface b=
ecause
they worry break security.

But, I don't know what exactly protected "the process is ptraced" check. If=
 anyone
explain the reason and we can remove it. I'm not againt at all.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
