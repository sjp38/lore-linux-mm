Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 682936B03A7
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:49:11 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id n131so12544257itg.4
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 04:49:11 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id c4si13445721iti.91.2017.02.28.04.49.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 04:49:10 -0800 (PST)
Date: Tue, 28 Feb 2017 13:49:06 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228124906.GC32474@worktop>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228124507.GG5680@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228124507.GG5680@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Feb 28, 2017 at 01:45:07PM +0100, Peter Zijlstra wrote:
> On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > +	/*
> > +	 * struct held_lock does not have an indicator whether in nmi.
> > +	 */
> > +	int nmi;
> 
> Do we really need this? Lockdep doesn't really know about NMI context,
> so its weird to now partially introduce it.

That is, see how nmi_enter() includes lockdep_off().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
