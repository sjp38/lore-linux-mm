Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id D31A56B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 12:08:08 -0400 (EDT)
Received: by mail-bk0-f50.google.com with SMTP id w10so1362193bkz.37
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 09:08:08 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id qa8si9387494bkb.50.2014.04.01.09.08.06
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 09:08:06 -0700 (PDT)
Date: Tue, 1 Apr 2014 19:07:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH RFC] drivers/char/mem: byte generating devices and
 poisoned mappings
Message-ID: <20140401160738.GA15175@node.dhcp.inet.fi>
References: <20140331211607.26784.43976.stgit@zurg>
 <20140401103617.GA10882@node.dhcp.inet.fi>
 <CALYGNiPvZSg7_b47+TbjhTzt0vBSRiXN8edVH=9A3YJOMQMqjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiPvZSg7_b47+TbjhTzt0vBSRiXN8edVH=9A3YJOMQMqjA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Yury Gribov <y.gribov@samsung.com>, Alexandr Andreev <aandreev@parallels.com>, Vassili Karpov <av1474@comtv.ru>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Apr 01, 2014 at 07:15:31PM +0400, Konstantin Khlebnikov wrote:
> On Tue, Apr 1, 2014 at 2:36 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > On Tue, Apr 01, 2014 at 01:16:07AM +0400, Konstantin Khlebnikov wrote:
> >> This patch adds 256 virtual character devices: /dev/byte0, ..., /dev/byte255.
> >> Each works like /dev/zero but generates memory filled with particular byte.
> >
> > Shouldn't /dev/byte0 be an alias for /dev/zero?
> > I see you reuse ZERO_PAGE(0) for that, but what about all these special
> > cases /dev/zero has?
> 
> What special cases? I found rss-accounting part, you've mentioned coredump.

I'm not sure what else is there. It's probably good idea to check all
users of vm_normal_page().

One thing is zero page coloring which some archs have.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
