Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8146B0254
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 15:21:08 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id cy9so46843730pac.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 12:21:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yu1si11564778pac.9.2016.01.22.12.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 12:21:07 -0800 (PST)
Date: Fri, 22 Jan 2016 12:21:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm: Rework virtual memory accounting
Message-Id: <20160122122106.c4e85c4501a049ad123e6153@linux-foundation.org>
In-Reply-To: <56A28613.5070104@de.ibm.com>
References: <20151228211015.GL2194@uranus>
	<CA+55aFzxT02gGCAokDFich=kjsf1VtvL=i315Uk9p=HRrCAY5Q@mail.gmail.com>
	<56A28613.5070104@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Andrew Morton <akpm@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, stable@vger.kernel.org, Greg KH <greg@kroah.com>

On Fri, 22 Jan 2016 20:42:11 +0100 Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> On 12/28/2015 11:22 PM, Linus Torvalds wrote:
> > On Mon, Dec 28, 2015 at 1:10 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> >> Really sorry for delays. Konstantin, I slightly updated the
> >> changelog (to point where problem came from). Linus are you
> >> fine with accounting not only anonymous memory in VmData?
> > 
> > The patch looks ok to me. I guess if somebody relies on old behavior
> > we may have to tweak it a bit, but on the whole this looks sane and
> > I'd be happy to merge it in the 4.5 merge window (and maybe even have
> > it marked for stable if it works out)
> > 
> 
> Just want to mention that this patch breaks older versions of valgrind 
> (including the current release)
> https://bugs.kde.org/show_bug.cgi?id=357833
> It is fixed in trunk (and even triggered some good cleanups, so the valgrind
> developers do NOT want it to get reverted). Rawhide already has the valgrind
> fix, others might not, so if we consider this for stable, things might break
> here and there, but in general this looks like a good cleanup.
> 

OK, thanks - that sounds reasonable, although a bit worrisome - what
other userspace was affected?  In some cases people won't find out for
years...

84638335900f199 ("mm: rework virtual memory accounting") did not have
the cc:stable tag so it should avoid the -stable dragnet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
