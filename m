Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 297F08E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 19:39:21 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id w4so5236072wrt.21
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:39:21 -0800 (PST)
Received: from mail-40135.protonmail.ch (mail-40135.protonmail.ch. [185.70.40.135])
        by mx.google.com with ESMTPS id b11si16018509wrx.217.2019.01.11.16.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 16:39:19 -0800 (PST)
Date: Sat, 12 Jan 2019 00:39:09 +0000
From: Esme <esploit@protonmail.ch>
Reply-To: Esme <esploit@protonmail.ch>
Subject: Re: [PATCH v2] rbtree: fix the red root
Message-ID: <KUuUVBQpzeIgmq4ZQZ9-XpXMPuesw3P5W4RAWrcv1PcYq3JkYhXWq3xhng9p8iCM2L6ec8Bg1hAt5PVh-41wO-hwhyzaxtRbx5tIPdbRwNg=@protonmail.ch>
In-Reply-To: <463fa1f6-4ee6-ef4d-431c-3c392c827792@lca.pw>
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <20190111231652.GN6310@bombadil.infradead.org>
 <463fa1f6-4ee6-ef4d-431c-3c392c827792@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Matthew Wilcox <willy@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, "walken@google.com" <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

I've been out today but return home tomorrow and can test any suggested fix=
es, or with different kernel settings.  Just let me know.

Esme


Sent with ProtonMail Secure Email.

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Friday, January 11, 2019 7:18 PM, Qian Cai <cai@lca.pw> wrote:

> On 1/11/19 6:16 PM, Matthew Wilcox wrote:
>
> > On Fri, Jan 11, 2019 at 03:58:43PM -0500, Qian Cai wrote:
> >
> > > diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
> > > index b7055b2a07d3..afad0213a117 100644
> > > --- a/lib/rbtree_test.c
> > > +++ b/lib/rbtree_test.c
> > > @@ -345,6 +345,17 @@ static int __init rbtree_test_init(void)
> > > check(0);
> > > }
> > >
> > > -   /*
> > > -   -   a little regression test to catch a bug may be introduced by
> > > -   -   6d58452dc06 (rbtree: adjust root color in rb_insert_color() o=
nly when
> > > -   -   necessary)
> > > -   */
> > > -   insert(nodes, &root);
> > > -   nodes->rb.__rb_parent_color =3D RB_RED;
> > > -   insert(nodes + 1, &root);
> > > -   erase(nodes + 1, &root);
> > > -   erase(nodes, &root);
> >
> > That's not a fair test! You're poking around in the data structure to
> > create the situation. This test would have failed before 6d58452dc06 to=
o.
> > How do we create a tree that has a red parent at root, only using inser=
t()
> > and erase()?
>
> If only I knew how to reproduce this myself, I might be able to figure ou=
t how
> it ends up with the red root in the first place.
