Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id B1EF56B012F
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 21:10:41 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id cz12so7887099veb.21
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 18:10:41 -0700 (PDT)
Received: from mail-ve0-x22d.google.com (mail-ve0-x22d.google.com [2607:f8b0:400c:c01::22d])
        by mx.google.com with ESMTPS id dm2si4057314vec.111.2014.03.18.18.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 18:10:41 -0700 (PDT)
Received: by mail-ve0-f173.google.com with SMTP id oy12so8138165veb.32
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 18:10:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1403181703470.7055@eggly.anvils>
References: <20140311045109.GB12551@redhat.com>
	<20140310220158.7e8b7f2a.akpm@linux-foundation.org>
	<20140311053017.GB14329@redhat.com>
	<20140311132024.GC32390@moon>
	<531F0E39.9020100@oracle.com>
	<20140311134158.GD32390@moon>
	<20140311142817.GA26517@redhat.com>
	<20140311143750.GE32390@moon>
	<20140311171045.GA4693@redhat.com>
	<20140311173603.GG32390@moon>
	<20140311173917.GB4693@redhat.com>
	<alpine.LSU.2.11.1403181703470.7055@eggly.anvils>
Date: Tue, 18 Mar 2014 18:10:40 -0700
Message-ID: <CA+55aFx0ZyCVrkosgTongBrNX6mJM4B8+QZQE1p0okk8ubbv7g@mail.gmail.com>
Subject: Re: bad rss-counter message in 3.14rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 18, 2014 at 5:38 PM, Hugh Dickins <hughd@google.com> wrote:
>
> And yes, it is possible (though very unusual) to find an anon page or
> swap entry in a VM_SHARED nonlinear mapping: coming from that horrid
> get_user_pages(write, force) case which COWs even in a shared mapping.

Hmm. Maybe we could just disallow that forced case.

It *used* to be a trivial "we can just do a COW", but that was back
when the VM was much simpler and we had no rmap's etc. So "that horrid
case" used to be a simple hack that wasn't painful. But I suspect we
could very easily just fail it instead of forcing a COW, if that would
make it simpler for the VM code.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
