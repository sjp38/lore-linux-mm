Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D56B96B0573
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 22:25:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g7so11110067pgp.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 19:25:34 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y77si825813pfj.168.2017.07.11.19.25.33
        for <linux-mm@kvack.org>;
        Tue, 11 Jul 2017 19:25:34 -0700 (PDT)
Date: Wed, 12 Jul 2017 11:24:49 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 05/16] lockdep: Implement crossrelease feature
Message-ID: <20170712022449.GC20323@X58A-UD3R>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-6-git-send-email-byungchul.park@lge.com>
 <20170711160454.GA28975@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711160454.GA28975@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Jul 11, 2017 at 06:04:54PM +0200, Peter Zijlstra wrote:
> 
> Sorry for the much delayed response; aside from the usual backlog I got
> unusually held up by family responsibilities.
> 
> My comments in the form of a patch..

Thank you.

I will apply it at the next spin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
