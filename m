Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 3F3356B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:36:39 -0400 (EDT)
Date: Tue, 17 Jul 2012 09:36:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <alpine.DEB.2.00.1207161642420.18232@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1207170929290.13599@router.home>
References: <1342221125.17464.8.camel@lorien2> <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com> <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com> <1342407840.3190.5.camel@lorien2> <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1207160915470.28952@router.home> <alpine.DEB.2.00.1207161253240.29012@chino.kir.corp.google.com> <alpine.DEB.2.00.1207161506390.32319@router.home> <alpine.DEB.2.00.1207161642420.18232@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Shuah Khan <shuah.khan@hp.com>, Pekka Enberg <penberg@kernel.org>, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Mon, 16 Jul 2012, David Rientjes wrote:

> > The kernel cannot check everything and will blow up in unexpected ways if
> > someone codes something stupid. There are numerous debugging options that
> > need to be switched on to get better debugging information to investigate
> > deper. Adding special code to replicate these checks is bad.
> >
>
> Disagree, CONFIG_SLAB does not blow up for a NULL name string and just
> corrupts userspace.

Ohh.. So far we only had science fiction. Now kernel fiction.... If you
could corrupt userspace using sysfs with a NULL string then you'd first
need to fix sysfs support.

And if you really want to be totally safe then I guess you need to audit
the kernel and make sure that every core kernel function that takes a
string argument does check for it to be NULL just in case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
