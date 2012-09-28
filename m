Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id A3C2B6B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 12:45:13 -0400 (EDT)
Received: by oagk14 with SMTP id k14so4033600oag.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:45:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50656733.3040609@gmail.com>
References: <1340959739.2936.28.camel@lappy> <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>
 <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>
 <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com> <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>
 <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com> <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com>
 <1347202600.5876.7.camel@sbsiddha-ivb> <505068F4.4080309@gmail.com>
 <50506A6C.30109@gmail.com> <50656733.3040609@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 28 Sep 2012 09:44:51 -0700
Message-ID: <CA+55aFyWdxD4Qb9PuPKKx_Ww_khYkWg1s-3QWVUwsTSXSUMG5w@mail.gmail.com>
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: suresh.b.siddha@intel.com, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On Fri, Sep 28, 2012 at 2:00 AM, Sasha Levin <levinsasha928@gmail.com> wrote:
>
> Is anyone planning on picking up Linus' patch? This is still not in -next even.

I was really hoping it would go through the regular channels and come
back to me that way, since I can't really test it, and it's bigger
than the trivial obvious one-liners that I'm happy to commit.

Hmm.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
