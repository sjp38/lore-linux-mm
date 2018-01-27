Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2B26B0003
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 17:43:31 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id r196so4355163itc.4
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 14:43:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e13sor3143129ite.51.2018.01.27.14.43.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Jan 2018 14:43:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180127222433.GA24097@codemonkey.org.uk>
References: <20180124013651.GA1718@codemonkey.org.uk> <20180127222433.GA24097@codemonkey.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 27 Jan 2018 14:43:29 -0800
Message-ID: <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Network Development <netdev@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Sat, Jan 27, 2018 at 2:24 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
> On Tue, Jan 23, 2018 at 08:36:51PM -0500, Dave Jones wrote:
>  > Just triggered this on a server I was rsync'ing to.
>
> Actually, I can trigger this really easily, even with an rsync from one
> disk to another.  Though that also smells a little like networking in
> the traces. Maybe netdev has ideas.

Is this new to 4.15? Or is it just that you're testing something new?

If it's new and easy to repro, can you just bisect it? And if it isn't
new, can you perhaps check whether it's new to 4.14 (ie 4.13 being
ok)?

Because that fs_reclaim_acquire/release() debugging isn't new to 4.15,
but it was rewritten for 4.14.. I'm wondering if that remodeling ended
up triggering something.

Adding PeterZ to the participants list in case he has ideas. I'm not
seeing what would be the problem in that call chain from hell.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
