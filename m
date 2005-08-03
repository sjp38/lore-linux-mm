Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.12.10/8.12.10) with ESMTP id j73AOXmp169524
	for <linux-mm@kvack.org>; Wed, 3 Aug 2005 10:24:33 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j73AOXX4181506
	for <linux-mm@kvack.org>; Wed, 3 Aug 2005 12:24:33 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j73AOXik012112
	for <linux-mm@kvack.org>; Wed, 3 Aug 2005 12:24:33 +0200
In-Reply-To: <Pine.LNX.4.61.0508022150530.10815@goblin.wat.veritas.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
Message-ID: <OFE9263DCA.5243AC8F-ON42257052.0038D22F-42257052.00392CDD@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Wed, 3 Aug 2005 12:24:30 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Roland McGrath <roland@redhat.com>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote on 08/02/2005 10:55:31 PM:

> > Go for it, I think whatever we do won't be wonderfully pretty.
>
> Here we are: get_user_pages quite untested, let alone the racy case,
> but I think it should work.  Please all hack it around as you see fit,
> I'll check mail when I get home, but won't be very responsive...

Ahh, just tested it and everythings seems to work (even for s390)..
I'm happy :-)

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
