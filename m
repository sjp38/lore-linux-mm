Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D310044043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 19:23:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z80so3629808pff.11
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 16:23:57 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b8si4993300ple.241.2017.11.08.16.23.56
        for <linux-mm@kvack.org>;
        Wed, 08 Nov 2017 16:23:56 -0800 (PST)
Date: Thu, 9 Nov 2017 09:23:47 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH] locking/lockdep: Revise
 Documentation/locking/crossrelease.txt
Message-ID: <20171109002347.GA24935@X58A-UD3R>
References: <1509344324-22399-1-git-send-email-byungchul.park@lge.com>
 <20171108093438.t5zjpsgealkiamlh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108093438.t5zjpsgealkiamlh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

On Wed, Nov 08, 2017 at 10:34:38AM +0100, Ingo Molnar wrote:
> 
> * Byungchul Park <byungchul.park@lge.com> wrote:
> 
> > I'm afraid the revision is not perfect yet. Of course, the document can
> > have got much better english by others than me.
> > 
> > But,
> > 
> > I think I should enhance it as much as I can, before they can help it
> > starting with a better one.
> > 
> > In addition, I removed verboseness as much as possible.
> > 
> > ----->8-----
> > From c7795104ca6ac6dd9f7fd944aee23a2011a6d3a2 Mon Sep 17 00:00:00 2001
> > From: Byungchul Park <byungchul.park@lge.com>
> > Date: Mon, 30 Oct 2017 14:51:26 +0900
> > Subject: [PATCH] locking/lockdep: Revise
> >  Documentation/locking/crossrelease.txt
> > 
> > The document should've been written with a better readability. Revise it
> > to enhance its readability.
> > 
> > Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> > ---
> >  Documentation/locking/crossrelease.txt | 388 +++++++++++++++------------------
> 
> Could you please run a spellchecker over this text? It's still full of typos and 
> various grammar mistakes...

Sure.. I have to.. I will look for a way and use it. Thanks a lot.

> Thanks,
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
