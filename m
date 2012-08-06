Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id D9CEF6B0069
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 16:58:27 -0400 (EDT)
Message-ID: <1344286699.27828.115.camel@twins>
Subject: Re: [PATCH v2 6/9] rbtree: low level optimizations in rb_erase()
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 22:58:19 +0200
In-Reply-To: <CANN689Gcca_Xr8GQSjJads8psz3PZpya+s8aWTt_goVt0+O4YA@mail.gmail.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-7-git-send-email-walken@google.com>
	 <1344262863.27828.56.camel@twins>
	 <CANN689Gcca_Xr8GQSjJads8psz3PZpya+s8aWTt_goVt0+O4YA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, 2012-08-06 at 13:50 -0700, Michel Lespinasse wrote:
> On Mon, Aug 6, 2012 at 7:21 AM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> > On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
> >> +                       /* Case 3: node's successor is leftmost under =
its
> >> +                        * right child subtree
> >
> > Hmm?
>=20
> Would 'leftmost under node's right child subtree' make more sense ?

Nah, its the comment style discrepancy..

 /*
  * Case 3: ....


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
