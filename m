Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id B2F306B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 16:04:30 -0400 (EDT)
Message-ID: <1343419466.32120.50.camel@twins>
Subject: Re: [PATCH 4/6] rbtree: faster augmented insert
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 27 Jul 2012 22:04:26 +0200
In-Reply-To: <1342787467-5493-5-git-send-email-walken@google.com>
References: <1342787467-5493-1-git-send-email-walken@google.com>
	 <1342787467-5493-5-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-07-20 at 05:31 -0700, Michel Lespinasse wrote:
> +static void augment_rotate(struct rb_node *rb_old, struct rb_node *rb_ne=
w)
> +{
> +       struct test_node *old =3D rb_entry(rb_old, struct test_node, rb);
> +       struct test_node *new =3D rb_entry(rb_new, struct test_node, rb);
> +
> +       /* Rotation doesn't change subtree's augmented value */
> +       new->augmented =3D old->augmented;
> +       old->augmented =3D augment_recompute(old);
> +}=20

> +static inline void augment_propagate(struct rb_node *rb)
> +{
> +       while (rb) {
> +               struct test_node *node =3D rb_entry(rb, struct test_node,=
 rb);
> +               node->augmented =3D augment_recompute(node);
> +               rb =3D rb_parent(&node->rb);
> +       }
> +}

So why do we have to introduce these two new function pointers to pass
along when they can both be trivially expressed in the old single
augment function?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
