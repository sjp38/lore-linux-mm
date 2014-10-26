Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 904E56B006C
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 14:40:20 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x13so500543wgg.32
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 11:40:20 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id w6si5960874wix.83.2014.10.26.11.40.18
        for <linux-mm@kvack.org>;
        Sun, 26 Oct 2014 11:40:19 -0700 (PDT)
Date: Sun, 26 Oct 2014 19:40:18 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141026184018.GA16309@amd>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <1413876435-11720-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413876435-11720-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

Hi!

> +
> +		/*
> +		 * There might have been an OOM kill while we were
> +		 * freezing tasks and the killed task might be still
> +		 * on the way out so we have to double check for race.
> +		 */

", so"

>  	/*
> +	 * PM-freezer should be notified that there might be an OOM killer on its
> +	 * way to kill and wake somebody up. This is too early and we might end
> +	 * up not killing anything but false positives are acceptable.

", but".

1,2 look good to me, 

Acked-by: Pavel Machek <pavel@ucw.cz>
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
