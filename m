Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5489A6B02BC
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 18:48:06 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id q63so68441798pfb.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 15:48:06 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id wu1si5583130pab.71.2015.12.27.15.48.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 27 Dec 2015 15:48:05 -0800 (PST)
Date: Mon, 28 Dec 2015 08:49:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: KVM: memory ballooning bug?
Message-ID: <20151227234910.GA26512@bbox>
References: <20151223052228.GA31269@bbox>
 <CALYGNiPob33YpCJTUkpaPNEqZTzg=NuN=EqCks+FMwe+CTZw5A@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CALYGNiPob33YpCJTUkpaPNEqZTzg=NuN=EqCks+FMwe+CTZw5A@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Rafael Aquini <aquini@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Dec 27, 2015 at 08:23:03PM +0300, Konstantin Khlebnikov wrote:
> On Wed, Dec 23, 2015 at 8:22 AM, Minchan Kim <minchan@kernel.org> wrote:
> > During my compaction-related stuff, I encountered some problems with
> > ballooning.
> >
> > Firstly, with repeated inflating and deflating cycle, guest memory(ie,
> > cat /proc/meminfo | grep MemTotal) decreased and couldn't recover.
> >
> > When I review source code, balloon_lock should cover release_pages_balloon.
> > Otherwise, struct virtio_balloon fields could be overwritten by race
> > of fill_balloon(e,g, vb->*pfns could be critical).
> 
> I guess, in original design fill and leak could be called only from single
> kernel thread which manages balloon. Seems like lock was added
> only for migration. So, locking scheme should be revisited for sure.
> Probably it's been broken by some of recent changes.

When I read git log, it seems to be broken from introdcuing
balloon_compaction.
Anyway, ballooning is out of my interest. I just wanted to go ahead
my test for a long time without any problem. ;-)
If you guys want to redesign the locking scheme fully, please do.
Until that, I can go with my test with my patches I just sent.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
