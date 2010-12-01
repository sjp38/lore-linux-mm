Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8518D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:40:53 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oB1LemCb022689
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 13:40:49 -0800
Received: from vws6 (vws6.prod.google.com [10.241.21.134])
	by kpbe20.cbf.corp.google.com with ESMTP id oB1LeFer032582
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 13:40:47 -0800
Received: by vws6 with SMTP id 6so2888630vws.6
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 13:40:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=tfDQhcNwhDeLz9jM5QHjDR_8WL+v6AWU3SJpZ@mail.gmail.com>
References: <919384632.877731291171499343.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	<1330724443.975931291231775834.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	<AANLkTi=tfDQhcNwhDeLz9jM5QHjDR_8WL+v6AWU3SJpZ@mail.gmail.com>
Date: Wed, 1 Dec 2010 13:40:43 -0800
Message-ID: <AANLkTike8iofk0QQxOeRpBwVf3K1gJLBDhSKXMDaDCA4@mail.gmail.com>
Subject: Re: oom is broken in mmotm 2010-11-09-15-31 tree?
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 1, 2010 at 12:15 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Dec 1, 2010 at 11:29 AM, CAI Qian <caiqian@redhat.com> wrote:
>>>
>>> Hi, just a head-up. When testing oom for this tree, my workstation is
>>> immediately having no response to ssh, Desktop actions and so on apart
>>> from ping. I am trying to bisect but looks like git public server is
>>> having problem.
>>
>> This turned out that it was introduced by,
>>
>> =A0d065bd810b6deb67d4897a14bfe21f8eb526ba99
>> =A0mm: retry page fault when blocking on disk transfer
>>
>> It was reproduced by:
>> 1) ssh to the test box.
>> 2) try to trigger oom a few times using a malloc program there.
>
> Interesting. That commit is not supposed to make any semantic
> difference at all. And even if we do end up in the retry path, the
> arch/x86/mm/fault.c code is very explicitly designed so that it
> retries only _once_.
>
> Michel, any ideas? I could see problems with the mmap_sem if
> VM_FAULT_OOM is set at the same time as VM_FAULT_RETRY, but I can't
> see how that could ever happen.
>
> Anybody?
>
> CAI, can you get any output from sysrq-W when this happens?

Things are known to be broken between
d065bd810b6deb67d4897a14bfe21f8eb526ba99 and
d88c0922fa0e2c021a028b310a641126c6d4b7dc. CAI, do you have that in
your tree ? Also, can you test at
d065bd810b6deb67d4897a14bfe21f8eb526ba99 with
d88c0922fa0e2c021a028b310a641126c6d4b7dc cherry-picked on ?

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
