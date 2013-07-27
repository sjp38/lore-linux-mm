Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id B6FE66B0031
	for <linux-mm@kvack.org>; Sat, 27 Jul 2013 02:25:15 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id o7so1152693lbv.3
        for <linux-mm@kvack.org>; Fri, 26 Jul 2013 23:25:13 -0700 (PDT)
Date: Sat, 27 Jul 2013 10:25:12 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130727062512.GC8508@moon>
References: <20130726201807.GJ8661@moon>
 <CALCETrUJa-Y40vnb6YOPry0dCXb3zCQ0y19i2yHWdzKR75HUzg@mail.gmail.com>
 <20130726211844.GB8508@moon>
 <CALCETrW7Ukh8KfKzpNgRc1D_5OK1o7bmEmFbtQTYoSoFiOSeKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW7Ukh8KfKzpNgRc1D_5OK1o7bmEmFbtQTYoSoFiOSeKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, Jul 26, 2013 at 02:36:51PM -0700, Andy Lutomirski wrote:
> >> Unless I'm misunderstanding this, it's saving the bit in the
> >> non-present PTE.  This sounds wrong -- what happens if the entire pmd
> >
> > It's the same as encoding pgoff in pte entry (pte is not present),
> > but together with pgoff we save soft-bit status, later on #pf we decode
> > pgoff and restore softbit back if it was there, pte itself can't disappear
> > since it holds pgoff information.
> 
> Isn't that only the case for nonlinear mappings?

Andy, I'm somehow lost, pte either exist with file encoded, either not,
when pud/ptes are zapped and any access to it should cause #pf pointing
kernel to read/write data from file to a page, if it happens on write
the pte is obtaining dirty bit (which always set together with soft
bit).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
