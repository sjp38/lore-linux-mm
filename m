Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 190996B0062
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 11:32:20 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so954967wgb.26
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 08:32:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1347202600.5876.7.camel@sbsiddha-ivb>
References: <1340959739.2936.28.camel@lappy> <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>
 <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>
 <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com> <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>
 <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com> <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com>
 <1347202600.5876.7.camel@sbsiddha-ivb>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 9 Sep 2012 08:31:57 -0700
Message-ID: <CA+55aFwej93o7aLe_xwV5CGuT0BDyAz54cyWm6Xe3wj-hCT3PA@mail.gmail.com>
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: suresh.b.siddha@intel.com
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On Sun, Sep 9, 2012 at 7:56 AM, Suresh Siddha <suresh.b.siddha@intel.com> wrote:
>
> yes but that is not a valid range I think because of the supported
> physical address bit limits of the processor and also the max
> architecture limit of 52 address bits.

But how could the caller possibly know that? None of those internal
PAT limits are exposed anywhere.

So doing the BUG_ON() is wrong. I'd suggest changing it to an EINVAL.

In fact, BUG_ON() is *always* wrong, unless it's a "my internal data
structures are so messed up that I cannot continue".

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
