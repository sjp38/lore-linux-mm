Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C190A6B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 19:16:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id w7so11430624pfd.4
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 16:16:08 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w8si3191810pfa.267.2017.12.03.16.16.06
        for <linux-mm@kvack.org>;
        Sun, 03 Dec 2017 16:16:07 -0800 (PST)
Date: Mon, 4 Dec 2017 09:15:46 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH] locking/Documentation: Revise
 Documentation/locking/crossrelease.txt
Message-ID: <20171204001546.GA12169@X58A-UD3R>
References: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
 <1510407214-31452-1-git-send-email-byungchul.park@lge.com>
 <20171111134524.GA16714@X58A-UD3R>
 <20171116000456.GB4394@X58A-UD3R>
 <20171116072237.jcztqvlnzerzyozh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171116072237.jcztqvlnzerzyozh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

On Thu, Nov 16, 2017 at 08:22:37AM +0100, Ingo Molnar wrote:
> 
> * Byungchul Park <byungchul.park@lge.com> wrote:
> 
> > On Sat, Nov 11, 2017 at 10:45:24PM +0900, Byungchul Park wrote:
> > > This is the big one including all of version 3.
> > > 
> > > You can take only this.
> > 
> > Hello Ingo,
> > 
> > Could you consider this?
> 
> Yeah, I'll have a look in a few days, but right now we are in the middle of the 
> merge window.

Excuse me but, could you take a look?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
