Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 86DCD6B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 00:03:35 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so13500563pbb.5
        for <linux-mm@kvack.org>; Tue, 25 Jun 2013 21:03:34 -0700 (PDT)
Date: Tue, 25 Jun 2013 21:03:31 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH] vmpressure: implement strict mode
Message-ID: <20130626040331.GA7993@teo>
References: <20130625175129.7c0d79e1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130625175129.7c0d79e1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, minchan@kernel.org, akpm@linux-foundation.org

On Tue, Jun 25, 2013 at 05:51:29PM -0400, Luiz Capitulino wrote:
> Currently, applications are notified for the level they registered for
> _plus_ higher levels.
> 
> This is a problem if the application wants to implement different
> actions for different levels. For example, an application might want
> to release 10% of its cache on level low, 50% on medium and 100% on
> critical. To do this, the application has to register a different fd
> for each event. However, fd low is always going to be notified and
> and all fds are going to be notified on level critical.
> 
> Strict mode solves this problem by strictly notifiying the event
> an fd has registered for. It's optional. By default we still notify
> on higher levels.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

In the documentation I would add more information about why exactly the
strict mode makes sense.

For example, the non-strict fd listener hooked onto the low level makes
sense for apps that just monitor reclaiming activity (like current Android
Activity Manager), hooking onto 'medium' non-strict mode makes sense for
simple load-balancing logic, and the new strict mode is for the cases when
an application wants to implement some fancy logic as it makes a decision
based on a concrete level.

Otherwise, it looks good.

Acked-by: Anton Vorontsov <anton@enomsg.org>

Thanks!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
