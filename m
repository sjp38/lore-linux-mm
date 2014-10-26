Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 984846B006C
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 14:49:28 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id h11so2691048wiw.8
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 11:49:27 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id s7si8118398wix.49.2014.10.26.11.49.26
        for <linux-mm@kvack.org>;
        Sun, 26 Oct 2014 11:49:27 -0700 (PDT)
Date: Sun, 26 Oct 2014 19:49:26 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141026184926.GB16309@amd>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <2156351.pWp6MNRoWm@vostro.rjw.lan>
 <20141021141159.GE9415@dhcp22.suse.cz>
 <4766859.KSKPTm3b0x@vostro.rjw.lan>
 <20141021142939.GG9415@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021142939.GG9415@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

Hi!
>  
> +/*
> + * Number of OOM killer invocations (including memcg OOM killer).
> + * Primarily used by PM freezer to check for potential races with
> + * OOM killed frozen task.
> + */
> +static atomic_t oom_kills = ATOMIC_INIT(0);
> +
> +int oom_kills_count(void)
> +{
> +	return atomic_read(&oom_kills);
> +}
> +
> +void note_oom_kill(void)
> +{
> +	atomic_inc(&oom_kills);
> +}
> +

Do we need the extra abstraction here? Maybe oom_kills should be
exported directly?
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
