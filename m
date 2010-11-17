Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B4BD96B0093
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 17:18:37 -0500 (EST)
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
References: <1289996638-21439-1-git-send-email-walken@google.com>
	 <1289996638-21439-4-git-send-email-walken@google.com>
	 <20101117125756.GA5576@amd> <1290007734.2109.941.camel@laptop>
	 <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 17 Nov 2010 23:18:46 +0100
Message-ID: <1290032326.2109.1281.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 14:05 -0800, Michel Lespinasse wrote:
>=20
> Really, my understanding is that not pre-allocating filesystem blocks
> is just fine. This is, after all, what happens with ext3 and it's
> never been reported as a bug (that I know of).
>=20
fwiw I'm perfectly fine with it

> If filesystem people's feedback is that they really want mlock() to
> continue pre-allocating blocks, maybe we can just do it using
> fallocate() rather than page_mkwrite() callbacks ?=20

Sounds sensible..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
