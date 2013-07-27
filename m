Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 48BEE6B0031
	for <linux-mm@kvack.org>; Sat, 27 Jul 2013 17:01:47 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id ec20so3174438lab.13
        for <linux-mm@kvack.org>; Sat, 27 Jul 2013 14:01:45 -0700 (PDT)
Date: Sun, 28 Jul 2013 01:01:43 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130727210143.GA2524@moon>
References: <20130726201807.GJ8661@moon>
 <CALCETrUJa-Y40vnb6YOPry0dCXb3zCQ0y19i2yHWdzKR75HUzg@mail.gmail.com>
 <20130726211844.GB8508@moon>
 <CALCETrW7Ukh8KfKzpNgRc1D_5OK1o7bmEmFbtQTYoSoFiOSeKw@mail.gmail.com>
 <20130727062512.GC8508@moon>
 <CALCETrWbF_e98w0d9-0tLOaTUv-mZv_RQgqOpuNiVaDOacHT0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWbF_e98w0d9-0tLOaTUv-mZv_RQgqOpuNiVaDOacHT0g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Sat, Jul 27, 2013 at 10:06:01AM -0700, Andy Lutomirski wrote:
> 
> That being said, a MAP_PRIVATE, un-cowed mapping must be clean -- if
> it had been (soft-)dirtied, it would also have been cowed.  So you
> might be okay.

Yas, as far as I know we are either cow'ed or in clean state, thus
either soft-bit set on #pf (and when reclaimed rest in file-pte)
or it remains clean and there is no change we need to track.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
