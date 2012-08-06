Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 1FBF46B005A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 10:22:23 -0400 (EDT)
Message-ID: <1344262930.27828.57.camel@twins>
Subject: Re: [PATCH v2 3/9] rbtree: add __rb_change_child() helper function
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 16:22:10 +0200
In-Reply-To: <1343946858-8170-4-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-4-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
> +static inline void

I would make that __always_inline, just to make sure GCC doesn't go
creative on us.

> +__rb_change_child(struct rb_node *old, struct rb_node *new,
> +                 struct rb_node *parent, struct rb_root *root)
> +{
> +       if (parent) {
> +               if (parent->rb_left =3D=3D old)
> +                       parent->rb_left =3D new;
> +               else
> +                       parent->rb_right =3D new;
> +       } else
> +               root->rb_node =3D new;
> +}=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
