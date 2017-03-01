Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C41F6B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 01:20:35 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 67so38293438pfg.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 22:20:35 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f1si3729552pga.93.2017.02.28.22.20.33
        for <linux-mm@kvack.org>;
        Tue, 28 Feb 2017 22:20:34 -0800 (PST)
Date: Wed, 1 Mar 2017 15:20:16 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301062016.GG11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228124507.GG5680@worktop>
 <20170228124906.GC32474@worktop>
MIME-Version: 1.0
In-Reply-To: <20170228124906.GC32474@worktop>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Feb 28, 2017 at 01:49:06PM +0100, Peter Zijlstra wrote:
> On Tue, Feb 28, 2017 at 01:45:07PM +0100, Peter Zijlstra wrote:
> > On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > > +	/*
> > > +	 * struct held_lock does not have an indicator whether in nmi.
> > > +	 */
> > > +	int nmi;
> > 
> > Do we really need this? Lockdep doesn't really know about NMI context,
> > so its weird to now partially introduce it.
> 
> That is, see how nmi_enter() includes lockdep_off().

Indeed. OK. I will fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
