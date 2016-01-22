Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD2F6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 15:20:12 -0500 (EST)
Received: by mail-lf0-f48.google.com with SMTP id m198so54112381lfm.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 12:20:11 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id j8si3369014lfd.169.2016.01.22.12.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 12:20:10 -0800 (PST)
Received: by mail-lf0-x241.google.com with SMTP id n70so4695845lfn.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 12:20:10 -0800 (PST)
Date: Fri, 22 Jan 2016 23:20:07 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH RFC] mm: Rework virtual memory accounting
Message-ID: <20160122202007.GG2262@uranus>
References: <20151228211015.GL2194@uranus>
 <CA+55aFzxT02gGCAokDFich=kjsf1VtvL=i315Uk9p=HRrCAY5Q@mail.gmail.com>
 <56A28613.5070104@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A28613.5070104@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Andrew Morton <akpm@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Jan 22, 2016 at 08:42:11PM +0100, Christian Borntraeger wrote:
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
> Christian

Thanks a huge for the report, Christian. I think this won't go for stable
for now, lets see if there are other tools which do the same trick setting
up zero to rlimit data. If indeed this would make more problems than solve
it, we might need to find a way for backward compatibility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
