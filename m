Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id D53306B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 10:29:55 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id j107so2185136qga.3
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:29:55 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id o5si6520366qck.6.2014.06.19.07.29.54
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 07:29:55 -0700 (PDT)
Date: Thu, 19 Jun 2014 09:29:52 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm: percpu: micro-optimize round-to-even
In-Reply-To: <20140619132536.GF11042@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1406190925430.2785@gentwo.org>
References: <1403172149-25353-1-git-send-email-linux@rasmusvillemoes.dk> <20140619132536.GF11042@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Jun 2014, Tejun Heo wrote:

> On Thu, Jun 19, 2014 at 12:02:29PM +0200, Rasmus Villemoes wrote:
> > This change shaves a few bytes off the generated code.
> >
> > Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> > ---
> >  mm/percpu.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> >
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index 2ddf9a9..978097f 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -720,8 +720,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
> >  	if (unlikely(align < 2))
> >  		align = 2;
> >
> > -	if (unlikely(size & 1))
> > -		size++;
> > +	size += size & 1;
>
> I'm not gonna apply this.  This isn't that hot a path.  It's not
> worthwhile to micro optimize code like this.

Dont we have an ALIGN() macro for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
