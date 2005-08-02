Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.12.10/8.12.10) with ESMTP id j72GiImp089682
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 16:44:18 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j72GiIeZ162926
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 18:44:18 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j72GiHDt008631
	for <linux-mm@kvack.org>; Tue, 2 Aug 2005 18:44:18 +0200
In-Reply-To: <Pine.LNX.4.58.0508020829010.3341@g5.osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
Message-ID: <OFD58BB32F.D2A5CB19-ON42257051.005B9FC2-42257051.005BF25A@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Tue, 2 Aug 2005 18:44:18 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@osdl.org> wrote on 08/02/2005 05:30:37 PM:

> > With the additional !pte_write(pte) check (and if I haven't overlooked
> > something which is not unlikely) s390 should work fine even without the
> > software-dirty bit hack.
>
> No it won't. It will just loop forever in a tight loop if somebody tries
> to put a breakpoint on a read-only location.

Yes, I have realized that as well nowe after staring at the code a little
bit longer. That maybe_mkwrite is really tricky.

> On the other hand, this being s390, maybe nobody cares?

Some will care. At least I do. I've tested the latest git with gdb and
it will indeed loop forever if I try to write to a read-only vma.

blue skies,
   Martin

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
