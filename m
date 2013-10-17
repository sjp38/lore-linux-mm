Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 588386B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 23:05:20 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so2063489pab.10
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 20:05:20 -0700 (PDT)
Received: by mail-ee0-f41.google.com with SMTP id b15so594950eek.28
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 20:05:16 -0700 (PDT)
Date: Wed, 16 Oct 2013 20:05:12 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [patch] mm, vmpressure: add high level
Message-ID: <20131017030512.GA21327@teo>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello David,

On Wed, Oct 16, 2013 at 05:43:55PM -0700, David Rientjes wrote:
> Vmpressure has two important levels: medium and critical.  Medium is 
> defined at 60% and critical is defined at 95%.
> 
> We have a customer who needs a notification at a higher level than medium, 
> which is slight to moderate reclaim activity, and before critical to start 
> throttling incoming requests to save memory and avoid oom.
> 
> This patch adds the missing link: a high level defined at 80%.
> 
> In the future, it would probably be better to allow the user to specify an 
> integer ratio for the notification rather than relying on arbitrarily 
> specified levels.

Does the customer need to differentiate the two levels (medium and high),
or the customer only interested in this (80%) specific level?

In the latter case, instead of adding a new level I would vote for adding
a [sysfs] knob for modifying medium level's threshold.

Thanks,

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
