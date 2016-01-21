Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id EC9306B0256
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 06:06:50 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u188so221390610wmu.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 03:06:50 -0800 (PST)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id i15si46572293wmd.87.2016.01.21.03.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 03:06:49 -0800 (PST)
Date: Thu, 21 Jan 2016 12:06:26 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [Xen-devel] [PATCH] cleancache: constify cleancache_ops
 structure
In-Reply-To: <56A0B6E7.9040201@citrix.com>
Message-ID: <alpine.DEB.2.10.1601211205540.2530@hadrien>
References: <1450904784-17139-1-git-send-email-Julia.Lawall@lip6.fr> <56A0B6E7.9040201@citrix.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>



On Thu, 21 Jan 2016, David Vrabel wrote:

> On 23/12/15 21:06, Julia Lawall wrote:
> > The cleancache_ops structure is never modified, so declare it as const.
> >
> > This also removes the __read_mostly declaration on the cleancache_ops
> > variable declaration, since it seems redundant with const.
> >
> > Done with the help of Coccinelle.
> >
> > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> >
> > ---
> >
> > Not sure that the __read_mostly change is correct.  Does it apply to the
> > variable, or to what the variable points to?
>
> The variable, so...

Thanks.  I'll update the patch, unless you have already fixed it.

julia

> > --- a/mm/cleancache.c
> > +++ b/mm/cleancache.c
> > @@ -22,7 +22,7 @@
> >   * cleancache_ops is set by cleancache_register_ops to contain the pointers
> >   * to the cleancache "backend" implementation functions.
> >   */
> > -static struct cleancache_ops *cleancache_ops __read_mostly;
> > +static const struct cleancache_ops *cleancache_ops;
>
> ...you want to retain the __read_mostly here.
>
> David
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
