Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 794A86B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 14:42:17 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id r129so226205169wmr.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 11:42:17 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id w2si10067052wjf.153.2016.01.22.11.42.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jan 2016 11:42:16 -0800 (PST)
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 22 Jan 2016 19:42:15 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id AAB5017D8059
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 19:42:19 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0MJgDaB6029658
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 19:42:13 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0MJgC4L028086
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 12:42:12 -0700
Subject: Re: [PATCH RFC] mm: Rework virtual memory accounting
References: <20151228211015.GL2194@uranus>
 <CA+55aFzxT02gGCAokDFich=kjsf1VtvL=i315Uk9p=HRrCAY5Q@mail.gmail.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56A28613.5070104@de.ibm.com>
Date: Fri, 22 Jan 2016 20:42:11 +0100
MIME-Version: 1.0
In-Reply-To: <CA+55aFzxT02gGCAokDFich=kjsf1VtvL=i315Uk9p=HRrCAY5Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Andrew Morton <akpm@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 12/28/2015 11:22 PM, Linus Torvalds wrote:
> On Mon, Dec 28, 2015 at 1:10 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>> Really sorry for delays. Konstantin, I slightly updated the
>> changelog (to point where problem came from). Linus are you
>> fine with accounting not only anonymous memory in VmData?
> 
> The patch looks ok to me. I guess if somebody relies on old behavior
> we may have to tweak it a bit, but on the whole this looks sane and
> I'd be happy to merge it in the 4.5 merge window (and maybe even have
> it marked for stable if it works out)
> 

Just want to mention that this patch breaks older versions of valgrind 
(including the current release)
https://bugs.kde.org/show_bug.cgi?id=357833
It is fixed in trunk (and even triggered some good cleanups, so the valgrind
developers do NOT want it to get reverted). Rawhide already has the valgrind
fix, others might not, so if we consider this for stable, things might break
here and there, but in general this looks like a good cleanup.

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
