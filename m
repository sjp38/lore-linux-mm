Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id BE2026B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:20:10 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id hz1so142951pad.20
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:20:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z3si3406734pdj.12.2014.08.27.16.20.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 16:20:08 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:20:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] x86: Speed up ioremap operations
Message-Id: <20140827162006.580e83d57696b5eba203b18c@linux-foundation.org>
In-Reply-To: <53FE6690.80608@sgi.com>
References: <20140827225927.364537333@asylum.americas.sgi.com>
	<20140827160610.4ef142d28fd7f276efd38a51@linux-foundation.org>
	<53FE6690.80608@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On Wed, 27 Aug 2014 16:15:28 -0700 Mike Travis <travis@sgi.com> wrote:

> 
> > 
> >> There are two causes for requiring a restart/reload of the drivers.
> >> First is periodic preventive maintenance (PM) and the second is if
> >> any of the devices experience a fatal error.  Both of these trigger
> >> this excessively long delay in bringing the system back up to full
> >> capability.
> >>
> >> The problem was tracked down to a very slow IOREMAP operation and
> >> the excessively long ioresource lookup to insure that the user is
> >> not attempting to ioremap RAM.  These patches provide a speed up
> >> to that function.
> > 
> > With what result?
> > 
> 
> Early measurements on our in house lab system (with far fewer cpus
> and memory) shows about a 60-75% increase.  They have a 31 devices,
> 3000+ cpus, 10+Tb of memory.  We have 20 devices, 480 cpus, ~2Tb of
> memory.  I expect their ioresource list to be about 5-10 times longer.
> [But their system is in production so we have to wait for the next
> scheduled PM interval before a live test can be done.]

So you expect 1+ hours?  That's still nuts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
