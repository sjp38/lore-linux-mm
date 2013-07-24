Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 047FB6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:37:37 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id ec20so514354lab.27
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 09:37:36 -0700 (PDT)
Date: Wed, 24 Jul 2013 20:37:34 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130724163734.GE24851@moon>
References: <20130724160826.GD24851@moon>
 <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 09:23:14AM -0700, Andy Lutomirski wrote:
> On Wed, Jul 24, 2013 at 9:08 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> > Andy Lutomirski reported that in case if a page with _PAGE_SOFT_DIRTY
> > bit set get swapped out, the bit is getting lost and no longer
> > available when pte read back.
> 
> Potentially silly question (due to my completely lack of understanding
> of how swapping works in Linux): what about file-backed pages?
> (Arguably these would be best supported by filesystems instead of by
> the core vm, in which case it might make sense to drop soft-dirty
> support for these pages entirely.)

Hi Andy, if I understand you correctly "file-backed pages" are carried
in pte with _PAGE_FILE bit set and the swap soft-dirty bit won't be
used on them but _PAGE_SOFT_DIRTY will be set on write if only I've
not missed something obvious (Pavel?).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
