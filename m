Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 174F76B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 23:44:18 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fa1so2032770pad.23
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 20:44:17 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so2011633pdj.16
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 20:44:14 -0700 (PDT)
Date: Wed, 16 Oct 2013 20:44:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, vmpressure: add high level
In-Reply-To: <20131017030512.GA21327@teo>
Message-ID: <alpine.DEB.2.02.1310162042050.30329@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com> <20131017030512.GA21327@teo>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 16 Oct 2013, Anton Vorontsov wrote:

> > Vmpressure has two important levels: medium and critical.  Medium is 
> > defined at 60% and critical is defined at 95%.
> > 
> > We have a customer who needs a notification at a higher level than medium, 
> > which is slight to moderate reclaim activity, and before critical to start 
> > throttling incoming requests to save memory and avoid oom.
> > 
> > This patch adds the missing link: a high level defined at 80%.
> > 
> > In the future, it would probably be better to allow the user to specify an 
> > integer ratio for the notification rather than relying on arbitrarily 
> > specified levels.
> 
> Does the customer need to differentiate the two levels (medium and high),
> or the customer only interested in this (80%) specific level?
> 

Only high.

> In the latter case, instead of adding a new level I would vote for adding
> a [sysfs] knob for modifying medium level's threshold.
> 

Hmm, doesn't seem like such a good idea.  If one process depends on this 
being 60% and another depends on it being 80%, we're stuck.  I think it's 
legitimate to have things like low, medium, high, and critical as rough 
approximations (and to keep backwards compatibility), but as mentioned in 
the changelog I want to extend the interface to allow integer writes to 
specify their own ratio.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
