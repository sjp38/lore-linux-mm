Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 448406B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:17:32 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ea20so532369lab.22
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 10:17:30 -0700 (PDT)
Date: Wed, 24 Jul 2013 21:17:28 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130724171728.GH8508@moon>
References: <20130724160826.GD24851@moon>
 <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
 <20130724163734.GE24851@moon>
 <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 10:06:53AM -0700, Andy Lutomirski wrote:
> > Hi Andy, if I understand you correctly "file-backed pages" are carried
> > in pte with _PAGE_FILE bit set and the swap soft-dirty bit won't be
> > used on them but _PAGE_SOFT_DIRTY will be set on write if only I've
> > not missed something obvious (Pavel?).
> 
> If I understand this stuff correctly, the vmscan code calls
> try_to_unmap when it reclaims memory, which makes its way into
> try_to_unmap_one, which clears the pte (and loses the soft-dirty bit).

Indeed, I was so stareing into swap that forgot about files. I'll do
a separate patch for that, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
