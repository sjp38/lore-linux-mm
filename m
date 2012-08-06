Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 91CA16B0069
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 17:36:31 -0400 (EDT)
Message-ID: <1344288982.27828.116.camel@twins>
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 23:36:22 +0200
In-Reply-To: <CANN689GbB5Rj3FmgP_RWj5EJVxJKBZS1WavZCKg0tuYR4vMZpg@mail.gmail.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-9-git-send-email-walken@google.com>
	 <1344263140.27828.59.camel@twins>
	 <CANN689GbB5Rj3FmgP_RWj5EJVxJKBZS1WavZCKg0tuYR4vMZpg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, 2012-08-06 at 14:34 -0700, Michel Lespinasse wrote:
> On Mon, Aug 6, 2012 at 7:25 AM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> > On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
> >> +struct rb_augment_callbacks {
> >> +       void (*propagate)(struct rb_node *node, struct rb_node *stop);
> >> +       void (*copy)(struct rb_node *old, struct rb_node *new);
> >> +       void (*rotate)(struct rb_node *old, struct rb_node *new);
> >> +};
> >
> > Should we make that const pointers? Daniel?
>=20
> I don't think it would hurt, but note that each function taking this
> as an argument takes it as a const struct rb_augment_callbacks *, so I
> doubt the extra consts would help either.

IIRC Daniel found it allowed some older GCC to inline more if the
function pointer itself was constant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
