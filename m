Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 559586B0038
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 17:42:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so16856161pfb.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 14:42:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c7si717453paq.28.2016.09.13.14.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 14:42:51 -0700 (PDT)
Date: Tue, 13 Sep 2016 23:42:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160913214244.GB5020@twins.programming.kicks-ass.net>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913150554.GI2794@worktop>
 <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
 <20160913193829.GA5016@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160913193829.GA5016@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <max.byungchul.park@gmail.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Sep 13, 2016 at 09:38:29PM +0200, Peter Zijlstra wrote:

> > > I _think_ you propose to keep track of all prior held locks and then use
> > > the union of the held list on the block-chain with the prior held list
> > > from the complete context.
> > 
> > Almost right. Only thing we need to do to consider the union is to
> > connect two chains of two contexts by adding one dependency 'b -> a'.
> 
> Sure, but how do you arrive at which connection to make. The document is
> entirely silent on this crucial point.
> 
> The union between the held-locks of the blocked and prev-held-locks of
> the release should give a fair indication I think, but then, I've not
> thought too hard on this yet.

s/union/intersection/

those that are in both sets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
