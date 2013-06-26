Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 685BB6B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 09:32:46 -0400 (EDT)
Date: Wed, 26 Jun 2013 09:32:40 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] vmpressure: implement strict mode
Message-ID: <20130626093240.2b9c15ac@redhat.com>
In-Reply-To: <20130626040331.GA7993@teo>
References: <20130625175129.7c0d79e1@redhat.com>
	<20130626040331.GA7993@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, minchan@kernel.org, akpm@linux-foundation.org

On Tue, 25 Jun 2013 21:03:31 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> On Tue, Jun 25, 2013 at 05:51:29PM -0400, Luiz Capitulino wrote:
> > Currently, applications are notified for the level they registered for
> > _plus_ higher levels.
> > 
> > This is a problem if the application wants to implement different
> > actions for different levels. For example, an application might want
> > to release 10% of its cache on level low, 50% on medium and 100% on
> > critical. To do this, the application has to register a different fd
> > for each event. However, fd low is always going to be notified and
> > and all fds are going to be notified on level critical.
> > 
> > Strict mode solves this problem by strictly notifiying the event
> > an fd has registered for. It's optional. By default we still notify
> > on higher levels.
> > 
> > Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> 
> In the documentation I would add more information about why exactly the
> strict mode makes sense.
> 
> For example, the non-strict fd listener hooked onto the low level makes
> sense for apps that just monitor reclaiming activity (like current Android
> Activity Manager), hooking onto 'medium' non-strict mode makes sense for
> simple load-balancing logic, and the new strict mode is for the cases when
> an application wants to implement some fancy logic as it makes a decision
> based on a concrete level.

OK, I'll respin. But you said it all already, so I'll base my text on
on what you wrote.

> Otherwise, it looks good.
> 
> Acked-by: Anton Vorontsov <anton@enomsg.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
