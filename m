Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2A07A6B01E3
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 12:02:11 -0400 (EDT)
Subject: Re: [rfc] forked kernel task and mm structures imbalanced on NUMA
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1275408030.27810.27637.camel@twins>
References: <20100601073343.GQ9453@laptop>
	 <1275408030.27810.27637.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 01 Jun 2010 18:02:24 +0200
Message-ID: <1275408144.27810.27644.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-06-01 at 18:00 +0200, Peter Zijlstra wrote:
> On Tue, 2010-06-01 at 17:33 +1000, Nick Piggin wrote:
> > +       sd->iter =3D iter->next;
>=20
> BTW, the (utter lack of) synchronization of sd->iter probably wants a
> comment somewhere ;-)

serialization that is,..

/me goes brew more tea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
