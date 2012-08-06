Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id E82956B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 10:25:49 -0400 (EDT)
Message-ID: <1344263140.27828.59.camel@twins>
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 16:25:40 +0200
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
> +struct rb_augment_callbacks {
> +       void (*propagate)(struct rb_node *node, struct rb_node *stop);
> +       void (*copy)(struct rb_node *old, struct rb_node *new);
> +       void (*rotate)(struct rb_node *old, struct rb_node *new);
> +};=20

Should we make that const pointers? Daniel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
