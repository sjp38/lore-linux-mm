Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 553566B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 16:13:11 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so88158422wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 13:13:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ci16si20442428wjb.126.2016.02.19.13.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 13:13:10 -0800 (PST)
Date: Fri, 19 Feb 2016 13:13:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] proc: do not include shmem and driver pages in
 /proc/meminfo::Cached
Message-Id: <20160219131307.a38646706cc514fcaf18793a@linux-foundation.org>
In-Reply-To: <CALYGNiMHAtaZfGovYeud65Eix8v0OSWSx8F=4K+pqF6akQah0A@mail.gmail.com>
References: <1455827801-13082-1-git-send-email-hannes@cmpxchg.org>
	<alpine.LSU.2.11.1602181422550.2289@eggly.anvils>
	<CALYGNiMHAtaZfGovYeud65Eix8v0OSWSx8F=4K+pqF6akQah0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Fri, 19 Feb 2016 09:40:45 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> >> What are your thoughts on this?
> >
> > My thoughts are NAK.  A misleading stat is not so bad as a
> > misleading stat whose meaning we change in some random kernel.
> >
> > By all means improve Documentation/filesystems/proc.txt on Cached.
> > By all means promote Active(file)+Inactive(file)-Buffers as often a
> > better measure (though Buffers itself is obscure to me - is it intended
> > usually to approximate resident FS metadata?).  By all means work on
> > /proc/meminfo-v2 (though that may entail dispiritingly long discussions).
> >
> > We have to assume that Cached has been useful to some people, and that
> > they've learnt to subtract Shmem from it, if slow or no swap concerns them.
> >
> > Added Konstantin to Cc: he's had valuable experience of people learning
> > to adapt to the numbers that we put out.
> >
> 
> I think everything will ok. Subtraction of shmem isn't widespread practice,
> more like secret knowledge. This wasn't documented and people who use
> this should be aware that this might stop working at any time. So, ACK.

It worries me as well - we're deliberately altering the behaviour of
existing userspace code.  Not all of those alterations will be welcome!

We could add a shiny new field into meminfo and train people to migrate
to that.  But that would just be a sum of already-available fields.  In
an ideal world we could solve all of this with documentation and
cluebatting (and some apologizing!).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
