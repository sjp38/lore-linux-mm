Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 76A1C6B0037
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:52:59 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ea20so611788lab.22
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:52:57 -0700 (PDT)
Date: Wed, 24 Jul 2013 22:52:56 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130724185256.GA24365@moon>
References: <20130724160826.GD24851@moon>
 <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
 <20130724163734.GE24851@moon>
 <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
 <20130724171728.GH8508@moon>
 <1374687373.7382.22.camel@dabdike>
 <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com>
 <20130724181516.GI8508@moon>
 <CALCETrV5NojErxWOc2RpuYKE0g8FfOmKB31oDz46CRu27hmDBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrV5NojErxWOc2RpuYKE0g8FfOmKB31oDz46CRu27hmDBA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 11:21:46AM -0700, Andy Lutomirski wrote:
> >
> > I fear for tracking soft-dirty-bit for swapped entries we sinply have
> > no other place than pte (still i'm quite open for ideas, maybe there
> > are a better way which I've missed).
> 
> I know approximately nothing about how swap and anon_vma work.
> 
> For files, sticking it in struct page seems potentially nicer,
> although finding a free bit might be tough.  (FWIW, I have plans to
> free up a page flag on x86 some time moderately soon as part of a
> completely unrelated project.)  I think this stuff really belongs to
> the address_space more than it belongs to the pte.

Well, some part of information already lays in pte (such as 'file' bit,
swap entries) so it looks natural i think to work on this level. but
letme think if use page struct for that be more convenient...

> 
> How do you handle the write syscall?

I fear I somehow miss your point here, could please alaborate a bit?
There is no additional code I know of being write() specific, just
a code for #PF exceptions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
