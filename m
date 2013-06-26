Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id DA4776B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 14:00:46 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz11so14639095pad.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2013 11:00:46 -0700 (PDT)
Date: Wed, 26 Jun 2013 11:00:43 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH] vmpressure: implement strict mode
Message-ID: <20130626180042.GA9827@teo>
References: <20130625175129.7c0d79e1@redhat.com>
 <20130626075051.GG29127@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130626075051.GG29127@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, akpm@linux-foundation.org

On Wed, Jun 26, 2013 at 04:50:51PM +0900, Minchan Kim wrote:
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
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> Shouldn't we make this default?
> What do you think about it?

Either way works and both modes have their use-cases (as I have described
in my previous mail). Changing the default mode is just unneeded churn,
IMO. As long as things are documented properly, we are good. :)

Thanks,

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
