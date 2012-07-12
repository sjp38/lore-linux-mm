Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 5D1A66B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 10:10:12 -0400 (EDT)
Message-ID: <1342102195.28010.4.camel@twins>
Subject: Re: [PATCH 00/13] rbtree updates
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 12 Jul 2012 16:09:55 +0200
In-Reply-To: <20120712011208.GA1152@google.com>
References: <1341876923-12469-1-git-send-email-walken@google.com>
	 <1342012996.3462.154.camel@twins> <20120712011208.GA1152@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Wed, 2012-07-11 at 18:12 -0700, Michel Lespinasse wrote:
> Do you mean the case you marked XXX ? it is actually parent that is
> red, which we know because we tested that a few lines earlier.
>=20
> > @@ -85,12 +104,27 @@ void rb_insert_color(struct rb_node *nod
> >                 } else if (rb_is_black(parent))
> >                         break;
> >
> > +               /*
> > +                * XXX
> > +                */
> >                 gparent =3D rb_red_parent(parent);
>=20
> See :)=20

D'0h, I got confused and thought the red was for the parent's parent,
not parent.

Quite.. ignore that then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
