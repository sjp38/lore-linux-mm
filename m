Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id D3D5B6B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 16:55:26 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id ha12so811483vcb.23
        for <linux-mm@kvack.org>; Fri, 26 Jul 2013 13:55:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130726201807.GJ8661@moon>
References: <20130726201807.GJ8661@moon>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 26 Jul 2013 13:55:04 -0700
Message-ID: <CALCETrUJa-Y40vnb6YOPry0dCXb3zCQ0y19i2yHWdzKR75HUzg@mail.gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, Jul 26, 2013 at 1:18 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> Andy reported that if file page get reclaimed we loose soft-dirty bit
> if it was there, so save _PAGE_BIT_SOFT_DIRTY bit when page address
> get encoded into pte entry. Thus when #pf happens on such non-present
> pte we can restore it back.
>

Unless I'm misunderstanding this, it's saving the bit in the
non-present PTE.  This sounds wrong -- what happens if the entire pmd
(or whatever the next level is called) gets zapped?  (Also, what
happens if you unmap a file and map a different file there?)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
