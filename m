Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 9275D6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 10:29:34 -0400 (EDT)
Message-ID: <1344263368.27828.60.camel@twins>
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 16:29:28 +0200
In-Reply-To: <1343946858-8170-9-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-9-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
> +void __rb_insert_augmented(struct rb_node *node, struct rb_root *root,
> +       void (*augment_rotate)(struct rb_node *old, struct rb_node *new))
> +{
> +       __rb_insert(node, root, augment_rotate);
> +}
> +EXPORT_SYMBOL(__rb_insert_augmented);
> +
> +void rb_erase_augmented(struct rb_node *node, struct rb_root *root,
> +                       const struct rb_augment_callbacks *augment)
> +{
> +       __rb_erase(node, root, augment);
> +}
> +EXPORT_SYMBOL(rb_erase_augmented);=20

=46rom a symmetry POV I'd say have both take the rb_augment_callbacks
thing. The two taking different arguments is confusing at best.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
