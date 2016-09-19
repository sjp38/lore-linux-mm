Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3EF86B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 23:02:11 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 20so117098149ioj.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 20:02:11 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id j83si23237959ite.35.2016.09.18.20.02.10
        for <linux-mm@kvack.org>;
        Sun, 18 Sep 2016 20:02:11 -0700 (PDT)
Date: Mon, 19 Sep 2016 11:59:09 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20160919025909.GG2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-16-git-send-email-byungchul.park@lge.com>
 <CACbG30_tz=tkkibzH1od+2jLPq3k1W-6qsf6vDB=rwQ-Fm3ygg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACbG30_tz=tkkibzH1od+2jLPq3k1W-6qsf6vDB=rwQ-Fm3ygg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nilay Vaish <nilayvaish@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Thu, Sep 15, 2016 at 12:25:51PM -0500, Nilay Vaish wrote:
> On 13 September 2016 at 04:45, Byungchul Park <byungchul.park@lge.com> wrote:
> > This document describes the concept of crossrelease feature, which
> > generalizes what causes a deadlock and how can detect a deadlock.
> >
> > Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> > ---
> >  Documentation/locking/crossrelease.txt | 785 +++++++++++++++++++++++++++++++++
> >  1 file changed, 785 insertions(+)
> >  create mode 100644 Documentation/locking/crossrelease.txt
> 
> Byungchul, I mostly skimmed through the document.  I suggest that we
> split this document.  The initial 1/4 of the document talks about
> lockdep's current implementation which I believe should be combined
> with the file: Documentation/locking/lockdep-design.txt. Tomorrow I
> would try to understand the document in detail and hopefully provide
> some useful comments.

Hello,

It was a korean traditional holliday for a week so I'm late.
And I also think 1/4 of it talks about original lockdep.

Thank you,
Byungchul

> 
> --
> Nilay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
